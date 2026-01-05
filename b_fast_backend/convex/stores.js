import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

// Add Store
export const addStore = mutation({
  args: {
    storeName: v.string(),
    description: v.string(),
    category: v.string(),
    tags: v.array(v.string()),
    address: v.object({
      street: v.string(),
      city: v.string(),
      state: v.string(),
      country: v.string(),
      zip: v.string(),
    }),
    contact: v.object({
      phone: v.string(),
      email: v.string(),
    }),
    settings: v.object({
      status: v.boolean(),
      storeType: v.string(),
      businessType: v.string(),
    }),
    owner: v.object({
      fullName: v.string(),
      phone: v.string(),
      email: v.string(),
    }),
    kycStatus: v.string({ enum: ["Pending", "Verified", "Rejected"] }),
    storeStatus: v.string({ enum: ["Active", "Inactive", "Suspended"] }),
  },
  handler: async (ctx, args) => {
    return await ctx.db.insert("stores", {
      ...args,
      createdAt: Date.now(),
    });
  },
});

// Add Store With Images
export const addStoreWithImages = mutation({
  args: {
    // All args from addStore
    storeName: v.string(),
    description: v.string(),
    category: v.string(),
    tags: v.array(v.string()),
    address: v.object({
      street: v.string(),
      city: v.string(),
      state: v.string(),
      country: v.string(),
      zip: v.string(),
    }),
    contact: v.object({
      phone: v.string(),
      email: v.string(),
    }),
    settings: v.object({
      status: v.boolean(),
      storeType: v.string(),
      businessType: v.string(),
    }),
    owner: v.object({
      fullName: v.string(),
      phone: v.string(),
      email: v.string(),
    }),
    kycStatus: v.string({ enum: ["Pending", "Verified", "Rejected"] }),
    storeStatus: v.string({ enum: ["Active", "Inactive", "Suspended"] }),

    // Optional media args
    media: v.optional(
      v.object({
        logo: v.optional(v.object({ url: v.string(), public_id: v.string() })),
        poster: v.optional(v.array(v.object({ url: v.string(), public_id: v.string() }))),
        gallery: v.optional(v.array(v.object({ url: v.string(), public_id: v.string() }))),
      })
    ),
  },
  handler: async (ctx, args) => {
    // Insert all args, which now include details and media
    return await ctx.db.insert("stores", {
      ...args,
      createdAt: Date.now(),
    });
  },
});

// Get All Stores
export const getAllStores = query({
  handler: async (ctx) => {
    return await ctx.db.query("stores").collect();
  },
});

// Get Store by ID
export const getStoreById = query({
  args: { id: v.id("stores") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  },
});

// Edit Store
export const editStore = mutation({
  args: {
    id: v.id("stores"),
    updates: v.object({
      storeName: v.optional(v.string()),
      description: v.optional(v.string()),
      category: v.optional(v.string()),
      tags: v.optional(v.array(v.string())),
      kycStatus: v.optional(v.string({ enum: ["Pending", "Verified", "Rejected"] })),
      storeStatus: v.optional(v.string({ enum: ["Active", "Inactive", "Suspended"] })),
      updatedAt: v.optional(v.number()),
    }),
  },
  handler: async (ctx, { id, updates }) => {
    await ctx.db.patch(id, updates);
    return await ctx.db.get(id);
  },
});

// Delete Store
export const deleteStore = mutation({
  args: { id: v.id("stores") },
  handler: async (ctx, { id }) => {
    await ctx.db.delete(id);
    return { message: "Store deleted" };
  },
});

// Update Media
export const updateStoreMedia = mutation({
  args: {
    id: v.id("stores"),
    media: v.object({
      logo: v.optional(v.object({ url: v.string(), public_id: v.string() })),
      poster: v.optional(v.array(v.object({ url: v.string(), public_id: v.string()}))),
      gallery: v.optional(v.array(v.object({ url: v.string(), public_id: v.string()}))),
    }),
  },
  handler: async (ctx, { id, media }) => {
    await ctx.db.patch(id, { media, updatedAt: Date.now() });
    return { success: true, message: "Media updated" };
  },
});

// Update KYC Status
export const updateKycStatus = mutation({
  args: {
    id: v.id("stores"),
    kycStatus: v.string({ enum: ["Pending", "Verified", "Rejected"] }),
  },
  handler: async (ctx, { id, kycStatus }) => {
    await ctx.db.patch(id, { kycStatus, updatedAt: Date.now() });
    return { success: true, message: "KYC Status updated" };
  },
});

// Update Store Status
export const updateStoreStatus = mutation({
  args: {
    id: v.id("stores"),
    storeStatus: v.string({ enum: ["Active", "Inactive", "Suspended"] }),
  },
  handler: async (ctx, { id, storeStatus }) => {
    await ctx.db.patch(id, { storeStatus, updatedAt: Date.now() });
    return { success: true, message: "Store Status updated" };
  },
});

// Store Stats
export const getStoreStats = query({
  handler: async (ctx) => {
    const stores = await ctx.db.query("stores").collect();
    return {
      totalStores: stores.length,
      totalActiveStores: stores.filter((s) => s.storeStatus === "Active").length,
      totalPendingKyc: stores.filter((s) => s.kycStatus === "Pending").length,
    };
  },
});