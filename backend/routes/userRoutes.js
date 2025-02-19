import express from 'express';
import { login, register, updateProfile, getProfile, forgotPassword, resetPassword, uploadImage } from '../controllers/userController.js';
import Protect from '../middleware/auth.js';
import multer from 'multer';

const router = express.Router();
const upload = multer({ storage: multer.memoryStorage() });

router.post('/login', (req, res, next) => {
    console.log('Login route hit');
    console.log('Request body:', req.body);
    console.log('Headers:', req.headers);
    login(req, res).catch((error) => {
        console.error('Login route error:', error);
        next(error);
    });
});
router.post('/register', register);
router.route('/profile').get(Protect, getProfile).put(Protect, updateProfile);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password/:resetToken', resetPassword);
router.post('/upload-image', Protect, upload.single('image'), uploadImage);

export default router;
