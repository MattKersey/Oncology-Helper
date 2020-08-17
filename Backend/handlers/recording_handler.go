package handlers

import (
	"bytes"
	"context"
	"io"
	"net/http"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo/gridfs"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// RecordingHandler handles recording requests to the API.
func RecordingHandler(w http.ResponseWriter, r *http.Request) {
	file := r.URL.Path[len("/recording/"):]

	opts := options.Client()
	opts.ApplyURI("mongodb://localhost:27018/")
	opts.SetMaxPoolSize(5)
	client, err := mongo.NewClient(opts)
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusInternalServerError)
		return
	}
	ctx := context.Background()
	err = client.Connect(ctx)
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusInternalServerError)
		return
	}
	defer client.Disconnect(ctx)
	database := client.Database("go-backend")
	collection := database.Collection("fs.files")

	switch r.Method {
	case "GET":
		getRecording(w, r, database, file)
	case "POST":
		postRecording(w, r, database)
	case "DELETE":
		deleteRecording(w, r, database, collection, file)
	}
}

func getRecording(w http.ResponseWriter, r *http.Request, db *mongo.Database, file string) {
	bucket, err := gridfs.NewBucket(db)
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusInternalServerError)
		return
	}

	buf := bytes.NewBuffer(nil)
	_, err = bucket.DownloadToStreamByName(file, buf)
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusBadRequest)
		return
	}

	w.Header().Add("Content-Type", "audio/mp3")
	w.Write(buf.Bytes())
}

func postRecording(w http.ResponseWriter, r *http.Request, db *mongo.Database) {
	f, fh, err := r.FormFile("recording")
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusBadRequest)
		return
	}
	defer f.Close()

	buf := bytes.NewBuffer(nil)
	_, err = io.Copy(buf, f)
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusInternalServerError)
		return
	}

	bucket, err := gridfs.NewBucket(db)
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusInternalServerError)
		return
	}

	uploadStream, err := bucket.OpenUploadStream(fh.Filename)
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusInternalServerError)
		return
	}
	defer uploadStream.Close()

	_, err = uploadStream.Write(buf.Bytes())
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusInternalServerError)
		return
	}

	w.Header().Add("Content-Type", "audio/mp3")
	w.Write(buf.Bytes())
}

func deleteRecording(w http.ResponseWriter, r *http.Request, db *mongo.Database, c *mongo.Collection, file string) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	var results bson.M
	err := c.FindOne(ctx, bson.M{"filename": file}).Decode(&results)
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusBadRequest)
		return
	}
	objID := results["_id"]

	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusBadRequest)
		return
	}
	bucket, err := gridfs.NewBucket(db)
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusInternalServerError)
		return
	}

	err = bucket.Delete(objID)
	if err != nil {
		http.Error(w, "{ \"error\":\""+err.Error()+"\" }", http.StatusInternalServerError)
		return
	}
}
