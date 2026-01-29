import User from '../models/User.model.js';

export const getUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('-password -otp -otpExpires');
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    res.json({ success: true, data: user });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const updateUserProfile = async (req, res) => {
  try {
    const { name, email, phoneNumber, profileImage, addressLine1, addressLine2, city, state, pincode } = req.body;
    const updates = {};
    if (name !== undefined) updates.name = name.trim();
    if (email !== undefined) updates.email = email.trim().toLowerCase();
    if (phoneNumber !== undefined) updates.phoneNumber = phoneNumber.trim();
    if (profileImage !== undefined) updates.profileImage = profileImage || undefined;
    if (addressLine1 !== undefined) updates.addressLine1 = addressLine1?.trim() || undefined;
    if (addressLine2 !== undefined) updates.addressLine2 = addressLine2?.trim() || undefined;
    if (city !== undefined) updates.city = city?.trim() || undefined;
    if (state !== undefined) updates.state = state?.trim() || undefined;
    if (pincode !== undefined) updates.pincode = pincode?.trim() || undefined;

    const user = await User.findByIdAndUpdate(
      req.user._id,
      updates,
      { new: true, runValidators: true }
    ).select('-password -otp -otpExpires');

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    res.json({ success: true, message: 'Profile updated successfully', data: user });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

export const changePassword = async (req, res) => {
  res.json({ success: true, message: 'Change password - Coming soon' });
};

