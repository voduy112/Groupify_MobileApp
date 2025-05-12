const User = require('../models/User');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const authController = {
    register: async (req, res) => {
    
        try {
            const { username, email, password,phoneNumber } = req.body;

            if (!username || !email || !password || !phoneNumber) {
                return res.status(400).json({ message: 'All fields are required' });
            }
            const salt = await bcrypt.genSalt(10);
            const hashedPassword = await bcrypt.hash(password, salt);
            // Create a new user instance

            const newUser = new User({
                username,
                email,
                password: hashedPassword,
                phoneNumber,
            });
            const user = await newUser.save();
            return res.status(200).json(user);
        } catch (error) {
            res.status(500).json({ message: 'Error registering user', error });
        }
    }, 
    login: async (req, res) => {
    try{
        const user = await User.findOne({ email: req.body.email });
        console.log(user);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        const isMatch = await bcrypt.compare(req.body.password, user.password);
        if (!isMatch) {
            return res.status(400).json({ message: 'Invalid credentials' });
        }
        if(user && isMatch){
            const {password, ...others} = user._doc;
            return res.status(200).json({...others});
        }
    }catch (error) {
        res.status(500).json({ message: 'Error logging in user', error });
    }
}

}

module.exports = authController;