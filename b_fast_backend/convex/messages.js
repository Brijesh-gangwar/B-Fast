import { mutation, query } from "./_generated/server.js";
import { v } from "convex/values";

// Send message to a single user
export const sendMessageToUser = mutation({
  args: { userId: v.string(), content: v.string() },
  handler: async (ctx, { userId, content }) => {
    await ctx.db.insert("messages", {
      userId,
      content,
      read: false,
      createdAt: Date.now(),
    });
    return { status: "sent to user" };
  },
});

// Send broadcast message to all users
export const sendMessageToAll = mutation({
  args: { content: v.string() },
  handler: async (ctx, { content }) => {
    const users = await ctx.db.query("userDetails").collect(); // assuming "userDetails" stores all users
    for (const user of users) {
      await ctx.db.insert("messages", {
        userId: user.userId,
        content,
        read: false,
        createdAt: Date.now(),
      });
    }
    return { status: "sent to all", count: users.length };
  },
});

// Get all messages for a user
export const getAllMessagesByUser = query({
  args: { userId: v.string() },
  handler: async (ctx, { userId }) => {
    return await ctx.db
      .query("messages")
      .withIndex("by_userId", q => q.eq("userId", userId))
      .order("desc")
      .collect();
  },
});

// Get unread messages
export const getUnreadMessagesByUser = query({
  args: { userId: v.string() },
  handler: async (ctx, { userId }) => {
    return await ctx.db
      .query("messages")
      .withIndex("by_userId", q => q.eq("userId", userId))
      .filter(q => q.eq(q.field("read"), false))
      .order("desc")
      .collect();
  },
});

// Get read messages
export const getReadMessagesByUser = query({
  args: { userId: v.string() },
  handler: async (ctx, { userId }) => {
    return await ctx.db
      .query("messages")
      .withIndex("by_userId", q => q.eq("userId", userId))
      .filter(q => q.eq(q.field("read"), true))
      .order("desc")
      .collect();
  },
});

// Mark message as read
export const markAsRead = mutation({
  args: { id: v.id("messages") },
  handler: async (ctx, { id }) => {
    await ctx.db.patch(id, { read: true });
    return { status: "marked as read" };
  },
});
