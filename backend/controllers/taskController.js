const mongoose = require('mongoose');
const Task = require('../models/Task');

// Helper to check valid MongoDB ObjectId string
const isValidObjectId = (id) => mongoose.Types.ObjectId.isValid(id);

// @desc    Create a new task
// @route   POST /api/tasks
// @access  Private
const createTask = async (req, res) => {
  try {
    const { title, description, status, priority, dueDate } = req.body;

    if (!title || !title.trim()) {
      return res.status(400).json({ message: 'Please provide a task title' });
    }

    // Automatically bind the task to req.user._id from protect middleware
    const task = await Task.create({
      user: req.user._id,
      title: title.trim(),
      description: description ? description.trim() : '',
      status: status || 'pending',
      priority: priority || 'medium',
      dueDate: dueDate || null,
    });

    return res.status(201).json(task);
  } catch (error) {
    if (error.name === 'ValidationError') {
      return res.status(400).json({ message: error.message });
    }
    console.error('Create Task Error:', error.message);
    return res.status(500).json({ message: 'Server error creating task' });
  }
};

// @desc    Get all tasks for authenticated user
// @route   GET /api/tasks
// @access  Private
const getTasks = async (req, res) => {
  try {
    // Strictly isolate query to req.user._id
    const tasks = await Task.find({ user: req.user._id }).sort({ createdAt: -1 });

    return res.status(200).json(tasks);
  } catch (error) {
    console.error('Get Tasks Error:', error.message);
    return res.status(500).json({ message: 'Server error retrieving tasks' });
  }
};

// @desc    Get single task by ID for authenticated user
// @route   GET /api/tasks/:id
// @access  Private
const getTaskById = async (req, res) => {
  try {
    const taskId = req.params.id;

    if (!isValidObjectId(taskId)) {
      return res.status(404).json({ message: 'Task not found' });
    }

    // Find task matching both task ID and req.user._id
    const task = await Task.findOne({ _id: taskId, user: req.user._id });

    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }

    return res.status(200).json(task);
  } catch (error) {
    console.error('Get Task By ID Error:', error.message);
    return res.status(500).json({ message: 'Server error retrieving task' });
  }
};

// @desc    Update task for authenticated user
// @route   PUT /api/tasks/:id
// @access  Private
const updateTask = async (req, res) => {
  try {
    const taskId = req.params.id;

    if (!isValidObjectId(taskId)) {
      return res.status(404).json({ message: 'Task not found' });
    }

    // Allowlisted fields update object
    const allowedUpdates = ['title', 'description', 'status', 'priority', 'dueDate'];
    const updates = {};

    for (const key of allowedUpdates) {
      if (req.body[key] !== undefined) {
        updates[key] = req.body[key];
      }
    }

    // Verify ownership before modifying
    const task = await Task.findOne({ _id: taskId, user: req.user._id });

    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }

    // Update with runValidators: true
    const updatedTask = await Task.findOneAndUpdate(
      { _id: taskId, user: req.user._id },
      updates,
      { new: true, runValidators: true }
    );

    return res.status(200).json(updatedTask);
  } catch (error) {
    if (error.name === 'ValidationError') {
      return res.status(400).json({ message: error.message });
    }
    console.error('Update Task Error:', error.message);
    return res.status(500).json({ message: 'Server error updating task' });
  }
};

// @desc    Delete task for authenticated user
// @route   DELETE /api/tasks/:id
// @access  Private
const deleteTask = async (req, res) => {
  try {
    const taskId = req.params.id;

    if (!isValidObjectId(taskId)) {
      return res.status(404).json({ message: 'Task not found' });
    }

    // Verify ownership and delete matching document
    const task = await Task.findOneAndDelete({ _id: taskId, user: req.user._id });

    if (!task) {
      return res.status(404).json({ message: 'Task not found' });
    }

    return res.status(200).json({ message: 'Task deleted successfully' });
  } catch (error) {
    console.error('Delete Task Error:', error.message);
    return res.status(500).json({ message: 'Server error deleting task' });
  }
};

module.exports = {
  createTask,
  getTasks,
  getTaskById,
  updateTask,
  deleteTask,
};
