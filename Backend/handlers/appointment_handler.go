package handlers

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type describedTimestamp struct {
	ID          int
	Description string
	Timestamp   float64
}

// AppointmentHandler handles appointment requests to the API.
func AppointmentHandler(w http.ResponseWriter, r *http.Request) {
	id := r.URL.Path[len("/appointment/"):]

	client, err := mongo.NewClient(options.Client().ApplyURI("mongodb://localhost:27018/"))
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusInternalServerError)
		return
	}
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	err = client.Connect(ctx)
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusInternalServerError)
		return
	}
	defer client.Disconnect(ctx)
	database := client.Database("go-backend")
	collection := database.Collection("appointments")

	switch r.Method {
	case "GET":
		if id == "" {
			readAll(ctx, w, r, collection, "date")
		} else {
			readByID(ctx, w, r, collection, id)
		}
	case "POST":
		createAppointment(ctx, w, r, collection)
	case "DELETE":
		delete(ctx, w, r, collection, id)
	case "PATCH":
		updateAppointment(ctx, w, r, collection, id)
	}
}

func convertTimestamps(tStrings []string) ([]describedTimestamp, error) {
	var timestamps = make([]describedTimestamp, 0)
	for _, s := range tStrings {
		var timestamp describedTimestamp
		err := json.Unmarshal([]byte(s), &timestamp)
		if err != nil {
			return timestamps, err
		}
		fmt.Println(timestamp, s)
		timestamps = append(timestamps, timestamp)
	}
	return timestamps, nil
}

func createAppointment(ctx context.Context, w http.ResponseWriter, r *http.Request, collection *mongo.Collection) {
	err := r.ParseForm()
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusBadRequest)
		return
	}

	doctor := r.FormValue("doctor")
	location := r.FormValue("location")
	date := r.FormValue("RC3339date")
	timestamps, err := convertTimestamps(r.Form["describedTimestamps"])
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusBadRequest)
		return
	}
	questionIDs, err := convertIDs(r.Form["questionIDs"])
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusBadRequest)
		return
	}
	result, err := collection.InsertOne(ctx, bson.D{
		{Key: "doctor", Value: doctor},
		{Key: "location", Value: location},
		{Key: "RC3339date", Value: date},
		{Key: "describedTimestamps", Value: timestamps},
		{Key: "questionIDs", Value: questionIDs},
	})
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusInternalServerError)
		return
	}
	var findResult bson.M
	if err := collection.FindOne(ctx, bson.M{"_id": result.InsertedID}).Decode(&findResult); err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(findResult)
}

func updateAppointment(ctx context.Context, w http.ResponseWriter, r *http.Request, collection *mongo.Collection, id string) {
	objID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusBadRequest)
		return
	}
	err = r.ParseForm()
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusBadRequest)
		return
	}
	var update = bson.D{{Key: "$set", Value: bson.D{}}}
	if doctor, ok := r.Form["doctor"]; ok {
		update[0].Value = append(update[0].Value.(primitive.D), primitive.E{Key: "doctor", Value: doctor[0]})
	}
	if location, ok := r.Form["location"]; ok {
		update[0].Value = append(update[0].Value.(primitive.D), primitive.E{Key: "location", Value: location[0]})
	}
	if date, ok := r.Form["RC3339date"]; ok {
		update[0].Value = append(update[0].Value.(primitive.D), primitive.E{Key: "RC3339date", Value: date[0]})
	}
	if timestampsString, ok := r.Form["describedTimestamps"]; ok {
		timestamps, err := convertTimestamps(timestampsString)
		if err != nil {
			http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusBadRequest)
			return
		}
		update[0].Value = append(update[0].Value.(primitive.D), primitive.E{Key: "describedTimestamps", Value: timestamps})
	}
	if questionIDStrings, ok := r.Form["questionIDs"]; ok {
		questionIDs, err := convertIDs(questionIDStrings)
		if err != nil {
			http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusBadRequest)
			return
		}
		update[0].Value = append(update[0].Value.(primitive.D), primitive.E{Key: "questionIDs", Value: questionIDs})
	}

	var result bson.M
	err = collection.FindOneAndUpdate(ctx, bson.M{"_id": objID}, update).Decode(&result)
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}
