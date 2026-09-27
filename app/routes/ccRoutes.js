import express from 'express';
const router = express.Router();
import mongoose from 'mongoose';
const CreditCard = require("../models/creditCard");

router.post('/', (req,res) => {
    const {
        ccNumber,
        expiration,
        ccv
    } = req.body
    const creditCard = new CreditCard({
        ccNumber,
        expiration,
        ccv
    })
    console.log("Saving CreditCard");
    creditCard
        .save()
        .then(result => {
            res.status(201).json({
                message: "CreditCard Saved",
                data: result
            })
        })
        .catch()

})

module.exports = router;
