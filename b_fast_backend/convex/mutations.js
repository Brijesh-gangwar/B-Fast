
// Update Payment Status: Patch payment status for an order
export const updatePaymentStatus = mutation({
  args: {
    orderId: v.id("orders"),
    paymentStatus: v.string(),
  },
  handler: async (ctx, { orderId, paymentStatus }) => {
    await ctx.db.patch(orderId, { paymentStatus });
    return { success: true };
  },
});
// ---------------------------
// PLACEHOLDER MUTATIONS/QUERIES FOR HTTP ROUTES
// ---------------------------

// Create User: Actually upsert user in DB
export const createUser = mutation({
  args: {
    userId: v.string(),
    name: v.string(),
    email: v.string(),
    phone: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const existing = await ctx.db
      .query("userDetails")
      .withIndex("by_userId", (q) => q.eq("userId", args.userId))
      .unique();
    if (existing) {
      await ctx.db.patch(existing._id, {
        name: args.name,
        email: args.email,
        phone: args.phone,
      });
      return { success: true, userId: args.userId, id: existing._id };
    }
    const id = await ctx.db.insert("userDetails", {
      ...args,
      userStatus: "Active",
      fcmToken: undefined,
      addresses: [],
    });
    return { success: true, userId: args.userId, id };
  },
});

// Add to Wishlist: Insert wishlist item
export const addToWishlist = mutation({
  args: {
    userId: v.string(),
    productId: v.id("products"),
  },
  handler: async (ctx, { userId, productId }) => {
    // Prevent duplicates
    const existing = await ctx.db
      .query("wishlist")
      .withIndex("by_userId", (q) => q.eq("userId", userId))
      .filter((q) => q.eq(q.field("productId"), productId))
      .unique();
    if (existing) return { success: true, id: existing._id };
    const id = await ctx.db.insert("wishlist", { userId, productId, createdAt: Date.now() });
    return { success: true, id };
  },
});

// Get Wishlist: Query wishlist items for user
export const getWishlistByUserId = query(async (ctx, { userId }) => {
  return await ctx.db.query("wishlist")
    .withIndex("by_userId", (q) => q.eq("userId", userId)) // assumes you created an index on userId
    .collect();
});

// Remove from Wishlist: Delete wishlist item
export const removeFromWishlist = mutation({
  args: {
    userId: v.string(),
    productId: v.id("products"),
  },
  handler: async (ctx, { userId, productId }) => {
    const item = await ctx.db
      .query("wishlist")
      .withIndex("by_userId", (q) => q.eq("userId", userId))
      .filter((q) => q.eq(q.field("productId"), productId))
      .unique();
    if (!item) return { success: false, error: "Not found" };
    await ctx.db.delete(item._id);
    return { success: true };
  },
});

// Get Cart: Query cart items for user
export const getCartByUserId = query(async (ctx, { userId }) => {
  return await ctx.db.query("cart")
    .withIndex("by_userId", (q) => q.eq("userId", userId)) // assumes you created an index on userId
    .collect();
});

// Update Cart Item: Patch quantity for cart item
export const updateCartItem = mutation({
  args: {
    userId: v.string(),
    productId: v.id("products"),
    quantity: v.number(),
  },
  handler: async (ctx, { userId, productId, quantity }) => {
    const item = await ctx.db
      .query("cart")
      .withIndex("by_userId", (q) => q.eq("userId", userId))
      .filter((q) => q.eq(q.field("productId"), productId))
      .unique();
    if (!item) return { success: false, error: "Not found" };
    await ctx.db.patch(item._id, { quantity });
    return { success: true };
  },
});




// Update Order Status: Patch order status
export const updateOrderStatus = mutation({
  args: {
    orderId: v.id("orders"),
    status: v.string(),
  },
  handler: async (ctx, { orderId, status }) => {
    await ctx.db.patch(orderId, { orderStatus: status });
    return { success: true };
  },
});
// convex/mutations.js
import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

// Helper mutation to get or create a default store
export const getOrCreateDefaultStore = mutation({
  args: {},
  handler: async (ctx) => {
    // Check if there's any existing store
    const existingStore = await ctx.db.query("stores").first();
    if (existingStore) {
      return existingStore._id;
    }
    
    // Create a default store if none exists
    const storeId = await ctx.db.insert("stores", {
      storeName: "Default Store",
      description: "Default store for orders",
      category: "General",
      tags: ["default"],
      address: {
        street: "123 Main St",
        city: "Default City",
        state: "Default State", 
        country: "Default Country",
        zip: "12345",
      },
      contact: {
        phone: "+1234567890",
        email: "store@example.com",
      },
      settings: {
        status: true,
        storeType: "Online",
        businessType: "Retail",
      },
      owner: {
        fullName: "Store Owner",
        phone: "+1234567890",
        email: "owner@example.com",
      },
      kycStatus: "Verified",
      storeStatus: "Active",
      createdAt: Date.now(),
    });
    
    return storeId;
  },
});

// ---------------------------
// USER MUTATIONS
// ---------------------------

// update user details
// ✅ Update User Details except addresses

export const updateUserDetail = mutation({
  args: {
    userId: v.string(),
    updatedFields: v.object({
      name: v.optional(v.string()),
      email: v.optional(v.string()),
      phone: v.optional(v.string()),
      fcmToken: v.optional(v.string()),
    }),
  },
  handler: async (ctx, { userId, updatedFields }) => {
    // Find the user by userId
    const user = await ctx.db
      .query("userDetails")
      .withIndex("by_userId", (q) => q.eq("userId", userId))
      .unique();

    if (!user) throw new Error("User not found");

    // Patch only the provided fields
    await ctx.db.patch(user._id, updatedFields);

    return { success: true, updatedFields };
  },
});


// ✅ Create  user details
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
      .withIndex("by_userId", (q) => q.eq("userId", args.userId))
      .unique();

    if (existing) {
      await ctx.db.patch(existing._id, {
        name: args.name,
        email: args.email,
        phone: args.phone,
      });
      return existing._id;
    }

    return await ctx.db.insert("userDetails", {
      ...args,
      userStatus: "Active",
      fcmToken: undefined,
      addresses: [],
    });
  },
});

// get orders by userId
export const getOrdersByUserId = query(async (ctx, { userId }) => {
  return await ctx.db.query("orders")
    .withIndex("by_userId", (q) => q.eq("userId", userId)) // assumes you created an index on userId
    .collect();
});


// ✅ Update FCM Token
export const updateFcmToken = mutation({
  args: { userId: v.string(), fcmToken: v.string() },
  handler: async (ctx, { userId, fcmToken }) => {
    const user = await ctx.db
      .query("userDetails")
      .withIndex("by_userId", (q) => q.eq("userId", userId))
      .unique();

    if (!user) throw new Error("User not found");
    await ctx.db.patch(user._id, { fcmToken });
    return { success: true };
  },
});


// ✅ Add Address with addressId
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
    // Find the user by userId
    const user = await ctx.db
      .query("userDetails")
      .withIndex("by_userId", (q) => q.eq("userId", userId))
      .unique();

    if (!user) throw new Error("User not found");

    // ✅ Add unique addressId
    const newAddress = { ...address, addressId: crypto.randomUUID() };

    await ctx.db.patch(user._id, {
      addresses: [...user.addresses, newAddress],
    });

    return { success: true, address: newAddress };
  },
});

// ✅ Get User Details
export const getUserDetails = query({
  args: { userId: v.string() },
  handler: async (ctx, args) => {
    const customers = await ctx.db.query("userDetails").collect();
    return customers.find(c => c.userId === args.userId) || null;
  },
});

// ✅ Check if user exists
export const isUserPresent = query({
  args: { userId: v.string() },
  handler: async (ctx, args) => {

    const customers = await ctx.db.query("userDetails").collect();
    

    const exists = customers.some(c => c.userId === args.userId);
    return exists; 
  },
});



// ---------------------------
// CART MUTATIONS
// ---------------------------

// ✅ Add to Cart
// ✅ Add to Cart with size, color, and price
export const addToCart = mutation({
  args: {
    userId: v.string(),
    productId: v.id("products"),
    quantity: v.number(),      // changed from float64 to number
    optionIndex: v.number(),   // size/price index
    colorIndex: v.number(),    // color index
  },
  handler: async (ctx, { userId, productId, quantity, optionIndex, colorIndex }) => {
    // Check if same product + same option/color combination exists
    const existing = await ctx.db
      .query("cart")
      .withIndex("by_userId", (q) => q.eq("userId", userId))
      .filter((q) => q.eq(q.field("productId"), productId))
      .filter((q) => q.eq(q.field("optionIndex"), optionIndex))
      .filter((q) => q.eq(q.field("colorIndex"), colorIndex))
      .unique();

    if (existing) {
      await ctx.db.patch(existing._id, {
        quantity: existing.quantity + quantity,
      });
      return existing._id;
    }

    // Insert new cart item
    return await ctx.db.insert("cart", {
      userId,
      productId,
      quantity,
      optionIndex,
      colorIndex,
      addedAt: Date.now(),
    });
  },
});


// ✅ Remove from Cart

export const removeFromCart = mutation({
  args: { cartId: v.id("cart") }, // use cart _id
  handler: async (ctx, { cartId }) => {
    const item = await ctx.db.get(cartId);

    if (!item) throw new Error("Item not found in cart");

    await ctx.db.delete(cartId);
    return { success: true };
  },
});


// ✅ Get all products
export const getAllProducts = query({
  args: {},
  handler: async (ctx) => {
    return await ctx.db.query("products").collect();
  },
});

// Get product by ID
export const getProductById = query({
  args: { id: v.id("products") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  },
});


export const createOrderFromCart = mutation({
  args: {
    userId: v.string(),
    addressId: v.string(),
    orderId: v.string(),
    paymentId: v.optional(v.string()),
    storeId: v.id("stores"),
    paymentStatus: v.optional(
      v.union(v.literal("Pending"), v.literal("SUCCESS"), v.literal("Failed"),v.literal("Not paid"))
    ),
    paymentMethod: v.optional(
      v.union(
        v.literal("Cash on Delivery"),
        v.literal("Card"),
        v.literal("UPI"),
        v.literal("DROP_CHECKOUT")
      )
    ),
  },
  handler: async (
    ctx,
    { userId, addressId, orderId, paymentId, paymentMethod, paymentStatus, storeId }
  ) => {
    // 1️⃣ Get cart items
    const cartItems = await ctx.db
      .query("cart")
      .withIndex("by_userId", (q) => q.eq("userId", userId))
      .collect();

    if (cartItems.length === 0) throw new Error("Cart is empty");

    // 2️⃣ Build snapshot
    const snapshotItems = [];
    for (const item of cartItems) {
      const product = await ctx.db.get(item.productId);
      if (!product) continue;

      // Map indexes to actual values
      const selectedSize = Array.isArray(product.size)
        ? product.size[item.optionIndex] || product.size[0]
        : product.size;
      const selectedPrice = Array.isArray(product.price)
        ? product.price[item.optionIndex] || product.price[0]
        : product.price;
      const selectedColor = Array.isArray(product.color)
        ? product.color[item.colorIndex] || product.color[0]
        : product.color;

      snapshotItems.push({
        productId: item.productId,
        name: product.name,
        price: selectedPrice,
        quantity: item.quantity,
        size: selectedSize,
        color: selectedColor,
        category: product.category,
        subCategory: product.subCategory,
        image: product.images?.[0]?.url ?? "",
      });
    }

    // 3️⃣ Fetch user details
    const user = await ctx.db
      .query("userDetails")
      .withIndex("by_userId", (q) => q.eq("userId", userId))
      .unique();

    if (!user) throw new Error("User not found");

    const selectedAddress = user.addresses.find(
      (addr) => addr.addressId === addressId
    );
    if (!selectedAddress) throw new Error("Address not found");

    // 4️⃣ Calculate total
    const total = snapshotItems.reduce(
      (sum, item) => sum + item.price * item.quantity,
      0
    );

    // 5️⃣ Insert order
    const docId = await ctx.db.insert("orders", {
      orderId,
      userId,
      storeId,
      items: snapshotItems,
      address: {
        label: selectedAddress.label,
        street: selectedAddress.street,
        city: selectedAddress.city,
        state: selectedAddress.state,
        zip: selectedAddress.zip,
        country: selectedAddress.country,
        latitude: selectedAddress.latitude ?? "",
        longitude: selectedAddress.longitude ?? "",
      },
      total,
      taxes: 0,
      deliveryFee: 0,
      paymentId: paymentId ?? undefined,
      paymentStatus: paymentStatus ?? "Pending",
      paymentMethod: paymentMethod ?? "Cash on Delivery",
      orderStatus: "Pending",
      createdAt: Date.now(),
    });

    // 6️⃣ Clear cart
    for (const item of cartItems) {
      await ctx.db.delete(item._id);
    }

    return { orderId, docId, paymentId };
  },
});




// remove address using addressId and userid

export const removeAddress = mutation({
  args: {
    userId: v.string(),
    addressId: v.string(),
  },
  handler: async (ctx, { userId, addressId }) => {
    // Find the user by userId
    const user = await ctx.db
      .query("userDetails")
      .withIndex("by_userId", (q) => q.eq("userId", userId))
      .unique();

    if (!user) throw new Error("User not found");

    // Filter out the address to remove
    const updatedAddresses = user.addresses.filter(
      (addr) => addr.addressId !== addressId
    );

    await ctx.db.patch(user._id, { addresses: updatedAddresses });

    return { success: true };
  },
});

// ✅ Update Address by addressId
export const updateAddress = mutation({
  args: {
    userId: v.string(),
    addressId: v.string(),
    updatedFields: v.object({
      label: v.optional(v.string()),
      street: v.optional(v.string()),
      city: v.optional(v.string()),
      state: v.optional(v.string()),
      zip: v.optional(v.string()),
      country: v.optional(v.string()),
      latitude: v.optional(v.string()),
      longitude: v.optional(v.string()),
    }),
  },
  handler: async (ctx, { userId, addressId, updatedFields }) => {
    // Find the user by userId
    const user = await ctx.db
      .query("userDetails")
      .withIndex("by_userId", (q) => q.eq("userId", userId))
      .unique();

    if (!user) throw new Error("User not found");

    // Update the specific address
    const updatedAddresses = user.addresses.map((addr) => {
      if (addr.addressId === addressId) {
        return { ...addr, ...updatedFields };
      }
      return addr;
    });

    await ctx.db.patch(user._id, { addresses: updatedAddresses });

    const updatedAddress = updatedAddresses.find(
      (addr) => addr.addressId === addressId
    );

    return { success: true, address: updatedAddress };
  },
});

