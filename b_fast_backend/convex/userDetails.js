// convex/userDetails.ts
import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

// Upsert user details
export const upsertUserDetails = mutation({
  args: {
    userId: v.string(),
    name: v.string(),
    email: v.string(),
    phone: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const existing = await ctx.db
      .query("userDetails")
      .withIndex("by_userId", q => q.eq("userId", args.userId))
      .unique();

    if (existing) {
      await ctx.db.patch(existing._id, args);
      return existing._id;
    } else {
      return await ctx.db.insert("userDetails", {
        ...args, addresses: [],
        userStatus: "Active"
      });
    }
  },
});

// Update FCM token
export const updateFcmToken = mutation({
  args: { userId: v.string(), fcmToken: v.string() },
  handler: async (ctx, { userId, fcmToken }) => {
    const user = await ctx.db
      .query("userDetails")
      .withIndex("by_userId", q => q.eq("userId", userId))
      .unique();
    if (!user) throw new Error("User not found");
    await ctx.db.patch(user._id, { fcmToken });
  },
});

// Add address
export const addAddress = mutation({
  args: {
    userId: v.string(),
    address: v.object({
      label: v.string(),
      street: v.string(),
      city: v.string(),
      state: v.string(),
      zip: v.string(),
      country: v.string(),
      latitude: v.optional(v.string()),
      longitude: v.optional(v.string()),
    }),
  },
  handler: async (ctx, { userId, address }) => {
    const user = await ctx.db
      .query("userDetails")
      .withIndex("by_userId", q => q.eq("userId", userId))
      .unique();
    if (!user) throw new Error("User not found");
    await ctx.db.patch(user._id, { addresses: [...user.addresses, { ...address, addressId: crypto.randomUUID() }] });
  },
});



export const getUserDetails = query({
  args: { userId: v.string() },
  handler: async (ctx, args) => {
    const user = await ctx.db.query("userDetails").collect();
    return user.find(c => c.userId === args.userId) || null;
  },
});