import { query, mutation } from "./_generated/server.js";
import { v } from "convex/values";

// Helper to populate order details
async function populateOrder(ctx, order) {
  // Get user
  const user = await ctx.db
    .query("userDetails")
    .withIndex("by_userId", (q) => q.eq("userId", order.userId))
    .unique();

  // Get products
  const products = await Promise.all(
    order.items.map(async (item) => {
      const product = await ctx.db.get(item.productId);
      return { ...item, product: product || null };
    })
  );

  // Get delivery agent (if assigned)
  let agent = null;
  if (order.deliveryAgent && order.deliveryAgent !== "N/A") {
    agent = await ctx.db
      .query("deliveryAgents")
      .filter((q) => q.eq(q.field("fullName"), order.deliveryAgent))
      .first();
  }

  return {
    ...order,
    user: user || null,
    items: products,
    deliveryAgent: agent || null,
  };
}


export const getAllOrders = query({
  args: {},
  handler: async (ctx) => {
    const orders = await ctx.db.query("orders").collect();
    return Promise.all(orders.map((o) => populateOrder(ctx, o)));
  },
});

export const getOrdersByStoreId = query({
  args: {
    storeId: v.id("stores"),
  },
  handler: async (ctx, { storeId }) => {
    const orders = await ctx.db
      .query("orders")
      .withIndex("by_storeId", (q) => q.eq("storeId", storeId))
      .order("desc")
      .collect();

    if (orders.length === 0) {
      return []; // Return empty array if no orders found
    }
    
    return Promise.all(orders.map((o) => populateOrder(ctx, o)));
  },
});

export const getAllSuccessfulPaymentOrders = query({
  args: {},
  handler: async (ctx) => {
    const orders = await ctx.db
      .query("orders")
      .filter((q) => q.eq(q.field("paymentStatus"), "paid"))
      .collect();
    return Promise.all(orders.map((o) => populateOrder(ctx, o)));
  },
});

export const getAcceptedOrders = query({
  args: {},
  handler: async (ctx) => {
    const orders = await ctx.db
      .query("orders")
      .filter((q) => q.eq(q.field("orderStatus"), "Confirmed"))
      .collect();
    return Promise.all(orders.map((o) => populateOrder(ctx, o)));
  },
});

export const getRejectedOrders = query({
  args: {},
  handler: async (ctx) => {
    const orders = await ctx.db
      .query("orders")
      .filter((q) => q.eq(q.field("orderStatus"), "Cancelled"))
      .collect();
    return Promise.all(orders.map((o) => populateOrder(ctx, o)));
  },
});

// --- UPDATED ROUTE FOR PENDING ORDERS BY STOREID ---
export const getPendingOrdersByStoreId = query({
  args: {
    storeId: v.id("stores"),
  },
  handler: async (ctx, { storeId }) => {
    const orders = await ctx.db
      .query("orders")
      .withIndex("by_storeId", (q) => q.eq("storeId", storeId))
      .filter((q) => q.eq(q.field("orderStatus"), "Pending"))
      .order("desc")
      .collect();
    
    if (orders.length === 0) {
      return [];
    }

    return Promise.all(orders.map((o) => populateOrder(ctx, o)));
  },
});


// Accept order (only if paid)
export const acceptOrder = mutation({
  args: { id: v.id("orders") },
  handler: async (ctx, { id }) => {
    const order = await ctx.db.get(id);
    if (!order) throw new Error("Order not found");
    // if (order.paymentStatus !== "Paid") {
    //   throw new Error("Order cannot be accepted by Admin until payment is completed");
    // }

    await ctx.db.patch(id, {
      orderStatus: "confirmed",
      updatedAt: Date.now(),
    });

    return { status: "accepted" };
  },
});

// Reject order (only if paid)
export const rejectOrder = mutation({
  args: { id: v.id("orders") },
  handler: async (ctx, { id }) => {
    const order = await ctx.db.get(id);
    if (!order) throw new Error("Order not found");
    // if (order.paymentStatus !== "Paid") {
    //   throw new Error("Order cannot be rejected by Admin until payment is completed");
    // }

    await ctx.db.patch(id, {
      orderStatus: "cancelled",
      updatedAt: Date.now(),
    });

    return { status: "rejected" };
  },
});

// Analytics Queries on Dashboard

// 1. Revenue API (sum of totals for delivered orders)
export const getRevenue = query({
  args: {},
  handler: async (ctx) => {
    const deliveredOrders = await ctx.db
      .query("orders")
      .filter((q) => q.eq(q.field("orderStatus"), "Delivered"))
      .collect();

    const revenue = deliveredOrders.reduce((sum, order) => sum + (order.total || 0), 0);
    return { revenue };
  },
});

// 2. Number of delivered orders
export const getDeliveredOrdersCount = query({
  args: {},
  handler: async (ctx) => {
    const deliveredOrders = await ctx.db
      .query("orders")
      .filter((q) => q.eq(q.field("orderStatus"), "Delivered"))
      .collect();

    return { count: deliveredOrders.length };
  },
});

// 4. Number of refunds (cancelled orders)
export const getRefundsCount = query({
  args: {},
  handler: async (ctx) => {
    const cancelledOrders = await ctx.db
      .query("orders")
      .filter((q) => q.eq(q.field("orderStatus"), "Cancelled"))
      .collect();

    return { count: cancelledOrders.length };
  },
});

// 5. Current Orders by status
export const getCurrentOrders = query({
  args: {},
  handler: async (ctx) => {
    const confirmed = await ctx.db
      .query("orders")
      .filter((q) => q.eq(q.field("orderStatus"), "Confirmed"))
      .collect();

    const shipped = await ctx.db
      .query("orders")
      .filter((q) => q.eq(q.field("orderStatus"), "Shipped"))
      .collect();

    const delivered = await ctx.db
      .query("orders")
      .filter((q) => q.eq(q.field("orderStatus"), "Delivered"))
      .collect();

    return {
      confirmed: confirmed.length,
      shipped: shipped.length,
      delivered: delivered.length,
    };
  },
});

// Get total number of orders
export const getTotalOrdersCount = query({
  args: {},
  handler: async (ctx) => {
    const allOrders = await ctx.db.query("orders").collect();
    return { count: allOrders.length };
  },
});

// Get all orders by userId
export const getOrdersByUserId = query({
  args: { userId: v.string() },
  handler: async (ctx, { userId }) => {
    const orders = await ctx.db
      .query("orders")
      .withIndex("by_userId", (q) => q.eq("userId", userId))
      .collect();

    const user = await ctx.db
      .query("userDetails")
      .withIndex("by_userId", (q) => q.eq("userId", userId))
      .unique();

    return orders.map((order) => ({
      ...order,
      user: user || null,
    }));
  },
});

// Get total number of orders by userId
export const getOrdersCountByUserId = query({
  args: { userId: v.string() },
  handler: async (ctx, { userId }) => {
    const orders = await ctx.db
      .query("orders")
      .withIndex("by_userId", (q) => q.eq("userId", userId))
      .collect();
    return { count: orders.length };
  },
});


// Assign Delivery Agent + set orderStatus = Shipped
export const assignDeliveryAgent = mutation({
  args: {
    id: v.id("orders"),
    deliveryAgentId: v.id("deliveryAgents"),
    deliveryMode: v.optional(v.string()),
    estimatedTime: v.optional(v.string()),
    instructions: v.optional(v.string()),
  },
  handler: async (ctx, { id, deliveryAgentId, deliveryMode, estimatedTime, instructions }) => {
    const order = await ctx.db.get(id);
    if (!order) throw new Error("Order not found");

    const agent = await ctx.db.get(deliveryAgentId);
    if (!agent) throw new Error("Delivery agent not found");

    await ctx.db.patch(id, {
      deliveryAgent: agent.employeeId,
      deliveryAgentStatus: "Assigned",
      deliveryMode: deliveryMode || "Standard",
      estimatedTime: estimatedTime || "N/A",
      instructions: instructions || order.instructions || "",
      orderStatus: "shipped",
      updatedAt: Date.now(),
    });

    return { success: true, message: "Delivery agent assigned successfully" };
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




/*

 App delivery agent endpoints

 */

// Get orders by delivery agent

export const getOrdersByDeliveryAgent = query({
  args: {
    employeeId: v.string(),
    deliveryAgentStatus: v.optional(v.string()),
    limit: v.optional(v.number()),
    cursor: v.optional(v.union(v.string(), v.null())),
  },

  handler: async (ctx, { employeeId, deliveryAgentStatus = null, limit = 10, cursor = null }) => {
    if (!employeeId) throw new Error("Delivery agent ID is required");

    // Build query
    let q;
    if (deliveryAgentStatus) {
      q = ctx.db
        .query("orders")
        .withIndex("by_deliveryAgent", (q) =>
          q.eq("deliveryAgent", employeeId).eq("deliveryAgentStatus", deliveryAgentStatus)
        );
    } else {
      q = ctx.db
        .query("orders")
        .withIndex("by_deliveryAgent", (q) => q.eq("deliveryAgent", employeeId));
    }

    // Sort by createdAt descending
    q = q.order("desc");

    // Paginate results
    const result = await q.paginate({ cursor: cursor || null, numItems: limit });

    // Attach store data to each order
    const ordersWithStoreData = await Promise.all(
      result.page.map(async (order) => {
        const store = await ctx.db.get(order.storeId);
        return {
          ...order,
          storeData: store
            ? {
                storeId: store._id,
                storeName: store.storeName,
                category: store.category,
                address: store.address,
                contact: store.contact,
                storeStatus: store.storeStatus,
              }
            : null,
        };
      })
    );

    return {
      data: ordersWithStoreData,
      isDone: result.isDone,
      continueCursor: result.continueCursor,
    };
  },
});



// old function without store address and details
// export const getOrdersByDeliveryAgent = query({
//   args: {
//     employeeId: v.string(),
//     deliveryAgentStatus: v.optional(v.string()),
//     limit: v.optional(v.number()),
//     cursor: v.optional(v.union(v.string(), v.null())),
//   },
//   handler: async (ctx, { employeeId, deliveryAgentStatus = null, limit = 10, cursor = null }) => {
//     if (!employeeId) throw new Error("Delivery agent ID is required");

//     let q;

//     if (deliveryAgentStatus) {
//       // use compound index on deliveryAgent + deliveryAgentStatus
//       q = ctx.db.query("orders").withIndex(
//         "by_deliveryAgent",
//         (q) =>
//           q.eq("deliveryAgent", employeeId).eq("deliveryAgentStatus", deliveryAgentStatus)
//       );
//     } else {
//       // only filter by deliveryAgent
//       q = ctx.db.query("orders").withIndex(
//         "by_deliveryAgent",
//         (q) => q.eq("deliveryAgent", employeeId)
//       );
//     }

//     q = q.order("desc");

//     // Use start cursor and limit
//     const result = await q.paginate({ cursor: cursor || null, numItems: limit });

//     return {
//       data: result.page,
//       isDone: result.isDone,
//       continueCursor: result.continueCursor,
//     };
//   }
// });





/**
 * Update delivery agent status
 */
export const updateDeliveryAgentStatus = mutation(
  async (ctx, { orderId, employeeId, deliveryAgentStatus }) => {
    const order = await ctx.db.get(orderId);
    if (!order) throw new Error("Order not found");
    if (order.deliveryAgent !== employeeId) {
      throw new Error("You are not authorized to update this order");
    }

    await ctx.db.patch(orderId, {
      deliveryAgentStatus,
      updatedAt: Date.now(),
    });

    return { success: true, deliveryAgentStatus };
  }
);

/**
 * Update payment status
 */
export const updatePaymentStatus = mutation(
  async (ctx, { orderId, employeeId, paymentStatus }) => {
    const order = await ctx.db.get(orderId);
    if (!order) throw new Error("Order not found");
    if (order.deliveryAgent !== employeeId) {
      throw new Error("You are not authorized to update this order");
    }

    await ctx.db.patch(orderId, {
      paymentStatus,
      updatedAt: Date.now(),
    });

    return { success: true, paymentStatus };
  }
);



// Update order status
export const updateOrderStatus = mutation({

  args: {
    orderId: v.id("orders"), 
    employeeId: v.string(),
    orderStatus: v.string(),
  },
  async handler(ctx, { orderId, employeeId, orderStatus }) {

    const order = await ctx.db.get(orderId);
    if (!order) {
      throw new Error("Order not found");
    }

    if (order.deliveryAgent !== employeeId) {
      throw new Error("You are not authorized to update this order");
    }


    await ctx.db.patch(order._id, {
      orderStatus,
      updatedAt: Date.now(),
    });


    if (orderStatus === "Delivered") {

      const agent = await ctx.db
        .query("deliveryAgents") 
        .withIndex("by_employeeId", (q) => q.eq("employeeId", employeeId))
        .unique();

      if (agent) {

        const currentDeliveries = agent.deliveries || 0;

        await ctx.db.patch(agent._id, {
          deliveries: currentDeliveries + 1,
        });
      } else {

        console.warn(`Agent with employeeId "${employeeId}" not found. Could not increment delivery count.`);
      }
    }


    return { success: true, orderStatus };
  },
});

