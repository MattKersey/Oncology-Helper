const mongoose = require('mongoose');

const DescribedTimestampSchema = mongoose.Schema({
    id: { type: ObjectId },
    description: { type: String },
    timestamp: { type: Number, required: true }
})

const AppointmentSchema = mongoose.Schema({
    id: { type: ObjectId, required: true },
    doctor: { type: String, required: true },
    location: { type: String, required: true },
    rc3339date: { type: String, required: true },
    describedTimestamps: {
        type: [
            {
                type: mongoose.Schema.Type.ObjectId,
                ref: 'address'
            }
        ],
        required: true
    },
    questionIds: { type: [Number], required: true }
})

const Appointment = mongoose.model('Appointment', AppointmentSchema);

module.exports = Appointment;