import Wallet from '../models/Wallet.model.js';
import Transaction from '../models/Transaction.model.js';

// Get wallet balance
export const getWalletBalance = async (req, res) => {
  try {
    let wallet = await Wallet.findOne({ userId: req.user._id });

    if (!wallet) {
      wallet = new Wallet({
        userId: req.user._id,
        balance: 0,
      });
      await wallet.save();
    }

    res.json({
      success: true,
      data: wallet,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Add money to wallet
export const addMoney = async (req, res) => {
  try {
    const { amount, paymentMethod } = req.body;

    let wallet = await Wallet.findOne({ userId: req.user._id });

    if (!wallet) {
      wallet = new Wallet({
        userId: req.user._id,
        balance: 0,
      });
    }

    // TODO: Process payment via payment gateway
    // For now, directly adding to wallet

    wallet.balance += amount;
    await wallet.save();

    // Create transaction record
    const transaction = new Transaction({
      userId: req.user._id,
      type: 'credit',
      amount,
      description: `Added money via ${paymentMethod}`,
      status: 'completed',
      referenceId: `TXN${Date.now()}`,
    });
    await transaction.save();

    res.json({
      success: true,
      message: 'Money added successfully',
      data: {
        wallet,
        transaction,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Get transactions
export const getTransactions = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const transactions = await Transaction.find({ userId: req.user._id })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Transaction.countDocuments({ userId: req.user._id });

    res.json({
      success: true,
      data: {
        transactions,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit),
        },
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Transfer money
export const transferMoney = async (req, res) => {
  try {
    const { toUserId, amount } = req.body;

    const fromWallet = await Wallet.findOne({ userId: req.user._id });
    const toWallet = await Wallet.findOne({ userId: toUserId });

    if (!fromWallet || fromWallet.balance < amount) {
      return res.status(400).json({
        success: false,
        message: 'Insufficient balance',
      });
    }

    if (!toWallet) {
      const newWallet = new Wallet({
        userId: toUserId,
        balance: 0,
      });
      await newWallet.save();
      toWallet = newWallet;
    }

    // Deduct from sender
    fromWallet.balance -= amount;
    await fromWallet.save();

    // Add to receiver
    toWallet.balance += amount;
    await toWallet.save();

    // Create transactions
    const debitTransaction = new Transaction({
      userId: req.user._id,
      type: 'debit',
      amount,
      description: `Transferred to user ${toUserId}`,
      status: 'completed',
      referenceId: `TXN${Date.now()}`,
    });
    await debitTransaction.save();

    const creditTransaction = new Transaction({
      userId: toUserId,
      type: 'credit',
      amount,
      description: `Received from user ${req.user._id}`,
      status: 'completed',
      referenceId: `TXN${Date.now()}`,
    });
    await creditTransaction.save();

    res.json({
      success: true,
      message: 'Money transferred successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

