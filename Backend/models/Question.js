const mongoose = require('mongoose');

const QuestionSchema = mongoose.Schema({
    id: { type: ObjectId, required: true },
    questionString: { type: String, required: true },
    description: { type: String },
    pin: { type: Boolean, required: true },
    appointmentIds: { type: [ObjectId], required: true }
})