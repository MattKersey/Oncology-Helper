package handlers

import (
	"context"
	"encoding/json"
	"net/http"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func convertIDs(IDstrings []string) ([]primitive.ObjectID, error) {
	var objIDs = make([]primitive.ObjectID, 0)
	for _, s := range IDstrings {
		objID, err := primitive.ObjectIDFromHex(s)
		if err != nil {
			return objIDs, err
		}
		objIDs = append(objIDs, objID)
	}
	return objIDs, nil
}

func readAll(ctx context.Context, w http.ResponseWriter, r *http.Request, collection *mongo.Collection, sort string) {
	opts := options.Find()
	if sort != "" {
		opts.SetSort(bson.D{{Key: sort, Value: 1}})
	}
	cursor, err := collection.Find(ctx, bson.D{}, opts)
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusInternalServerError)
		return
	}
	var result []bson.M
	if err = cursor.All(ctx, &result); err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}

func readByID(ctx context.Context, w http.ResponseWriter, r *http.Request, collection *mongo.Collection, id string) {
	objID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusBadRequest)
		return
	}
	var result bson.M
	if err := collection.FindOne(ctx, bson.M{"_id": objID}).Decode(&result); err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}

func delete(ctx context.Context, w http.ResponseWriter, r *http.Request, collection *mongo.Collection, id string) {
	objID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusBadRequest)
		return
	}
	var result bson.M
	if err := collection.FindOne(ctx, bson.M{"_id": objID}).Decode(&result); err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusInternalServerError)
		return
	}
	_, err = collection.DeleteOne(ctx, bson.D{
		{Key: "_id", Value: objID},
	})
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}
