// convex/cart.ts
import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

// Add to cart
export const addToCart = mutation({
  args: { userId: v.string(), productId: v.id("products"), quantity: v.number() },
  handler: async (ctx, { userId, productId, quantity }) => {
    return await ctx.db.insert("cart", {
      userId,
      productId,
      quantity,
      addedAt: Date.now(),
      optionIndex: 0,
      colorIndex: 0
    });
  },
});

// Update cart item
export const updateCartItem = mutation({
  args: { id: v.id("cart"), quantity: v.number() },
  handler: async (ctx, { id, quantity }) => {
    await ctx.db.patch(id, { quantity });
  },
});

// Remove from cart
export const removeFromCart = mutation({
  args: { id: v.id("cart") },
  handler: async (ctx, { id }) => {
    await ctx.db.delete(id);
  },
});



// Get cart by userId

export const getCartByUserId = query(async (ctx, { userId }) => {
  const cartItems = await ctx.db.query("cart")
    .withIndex("by_userId", (q) => q.eq("userId", userId))
    .collect();

  // Fetch product details for each cart item
  const cartWithProductDetails = await Promise.all(
    cartItems.map(async (item) => {
      const product = await ctx.db.get(item.productId);
      return {
        ...item,
        product, // will be null if not found
      };
    })
  );

  return cartWithProductDetails;
});