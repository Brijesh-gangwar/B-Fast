// convex/wishlist.ts
import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

// Add product to wishlist
export const addToWishlist = mutation({
  args: { userId: v.string(), productId: v.id("products") },
  handler: async (ctx, { userId, productId }) => {
    return await ctx.db.insert("wishlist", {
      userId,
      productId,
      createdAt: Date.now(),
    });
  },
});

// Remove product from wishlist
export const removeFromWishlist = mutation({
  args: { id: v.id("wishlist") },
  handler: async (ctx, { id }) => {
    await ctx.db.delete(id);
  },
});

// Get wishlist for user
export const getWishlistByUserId = query(async (ctx, { userId }) => {
  const wishlistItems = await ctx.db.query("wishlist")
    .withIndex("by_userId", (q) => q.eq("userId", userId))
    .collect();

  // Fetch product details for each wishlist item
  const wishlistWithProductDetails = await Promise.all(
    wishlistItems.map(async (item) => {
      const product = await ctx.db.get(item.productId);
      return {
        ...item,
        product, // will be null if not found
      };
    })
  );

  return wishlistWithProductDetails;
});

