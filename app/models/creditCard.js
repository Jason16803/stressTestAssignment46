const mongoose = require("mongoose");

const creditCardSchema = new mongoose.Schema({
  ccNumber: {
    type: String,
    required: true,
  },
  expiration: {
    type: String,
    required: true,
  },
  ccv: {
    type: String,
    required: true,
  },
  createdAt: {
    type: String,
    required: true,
    default: Date.now,
  },
});

module.exports = mongoose.model("CreditCard", creditCardSchema);
