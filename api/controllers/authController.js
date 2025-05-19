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
    // GENERATE ACCESS TOKEN
    generateAccessToken: (user) => {
        return jwt.sign(
        {
            id: user._id,
            role: user.role,
        },
        process.env.ACCESS_TOKEN_SECRET,
        { expiresIn: "15m" }
        );
    },
    // GENERATE REFRESH TOKEN
    generateRefreshToken: (user) => {
        return jwt.sign(
        {
            id: user._id,
            role: user.role,
        },
        process.env.REFRESH_TOKEN_SECRET,
        { expiresIn: "30d" }
        );
    },
    login: async (req, res) => {
    try {
        const user = await User.findOne({ email: req.body.email });
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const isMatch = await bcrypt.compare(req.body.password, user.password);
        if (!isMatch) {
            return res.status(400).json({ message: 'Invalid credentials' });
        }

        // Nếu khớp thông tin:
        const accessToken = authController.generateAccessToken(user);
        const refreshToken = authController.generateRefreshToken(user);

        // Lưu refresh token vào DB
        await User.findByIdAndUpdate(user._id, { refreshToken });
        
        // Xóa password trước khi trả về cho client
        const { password, ...others } = user._doc;

        // Trả cả 2 token về phía client
        return res.status(200).json({
            ...others,
            accessToken,
            refreshToken
        });

    } catch (error) {
        res.status(500).json({ message: 'Error logging in user', error });
    }
},
    logout: async (req, res) => {
        try {
        const userId = req.user.id; 
        if (!userId) {
            return res.status(400).json({ message: "User ID is required" });
        }

        // Xoá refreshToken khỏi database
        await User.findByIdAndUpdate(userId, { refreshToken: null });
        
        res.status(200).json({ message: "Logout successful" });
    } catch (error) {
        res.status(500).json({ message: "Error during logout", error });
        }
    }
}

module.exports = authController;