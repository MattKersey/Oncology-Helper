package handlers

import (
	"context"
	"encoding/json"
	"net/http"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// QuestionHandler handles question requests to the API.
func QuestionHandler(w http.ResponseWriter, r *http.Request) {
	id := r.URL.Path[len("/question/"):]

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
	collection := database.Collection("questions")

	switch r.Method {
	case "GET":
		if id == "" {
			readAll(ctx, w, r, collection, "")
		} else {
			readByID(ctx, w, r, collection, id)
		}
	case "POST":
		createQuestion(ctx, w, r, collection)
	case "DELETE":
		delete(ctx, w, r, collection, id)
	case "PATCH":
		updateQuestion(ctx, w, r, collection, id)
	}
}

func createQuestion(ctx context.Context, w http.ResponseWriter, r *http.Request, collection *mongo.Collection) {
	err := r.ParseForm()
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusBadRequest)
		return
	}

	questionString := r.FormValue("questionString")
	description := r.FormValue("description")
	pin := false
	if r.FormValue("pin") == "true" {
		pin = true
	}
	appointmentIDs, err := convertIDs(r.Form["appointmentIDs"])
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusBadRequest)
		return
	}

	result, err := collection.InsertOne(ctx, bson.D{
		{Key: "questionString", Value: questionString},
		{Key: "description", Value: description},
		{Key: "pin", Value: pin},
		{Key: "appointmentIDs", Value: appointmentIDs},
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

func updateQuestion(ctx context.Context, w http.ResponseWriter, r *http.Request, collection *mongo.Collection, id string) {
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
	if questionString, ok := r.Form["questionString"]; ok {
		update[0].Value = append(update[0].Value.(primitive.D), primitive.E{Key: "questionString", Value: questionString[0]})
	}
	if description, ok := r.Form["description"]; ok {
		update[0].Value = append(update[0].Value.(primitive.D), primitive.E{Key: "description", Value: description[0]})
	}
	if pin, ok := r.Form["pin"]; ok {
		pinBool := false
		if pin[0] == "true" {
			pinBool = true
		}
		update[0].Value = append(update[0].Value.(primitive.D), primitive.E{Key: "pin", Value: pinBool})
	}
	if appointmentIDStrings, ok := r.Form["appointmentIDs"]; ok {
		appointmentIDs, err := convertIDs(appointmentIDStrings)
		if err != nil {
			http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusBadRequest)
			return
		}
		update[0].Value = append(update[0].Value.(primitive.D), primitive.E{Key: "appointmentIDs", Value: appointmentIDs})
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
