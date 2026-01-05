import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

// Add Store Partner
export const addStorePartner = mutation({
  args: {
    storeId: v.id("stores"),
    partnerName: v.string(),
    role: v.string(),
    email: v.string(),
    phone: v.string(),
    joinedAt: v.string(),
    status: v.string({ enum: ["Active", "Inactive"] }),
  },
  handler: async (ctx, args) => {
    return await ctx.db.insert("storePartners", args);
  },
});

// Get Partners by Store ID
export const getStorePartnersByStore = query({
  args: { storeId: v.id("stores") },
  handler: async (ctx, { storeId }) => {
    return await ctx.db.query("storePartners")
      .withIndex("by_storeId", (q) => q.eq("storeId", storeId))
      .collect();
  },
});
