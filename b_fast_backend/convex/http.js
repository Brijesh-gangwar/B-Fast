import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";
import { api } from "./_generated/api";

const http = httpRouter();

// GET all products
http.route({
  path: "/app/products/get/all",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const products = await ctx.runQuery(api.products.getAllProducts);
    return new Response(JSON.stringify(products), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});

// Update product status (Active / Out of Stock / Discontinued)
http.route({
  path: "/app/products/update-status",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const { id, status } = await req.json();
    if (!id || !status) {
      return new Response(
        JSON.stringify({ success: false, message: "Missing product id or status" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const result = await ctx.runMutation(api.products.updateProductStatus, { id, status });
    return new Response(JSON.stringify(result), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});

http.route({
  path: "/app/products/stock-alert",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const url = new URL(req.url);
    const storeId = url.searchParams.get("storeId");
    const thresholdParam = url.searchParams.get("threshold");

    if (!storeId) {
      return new Response(
        JSON.stringify({ success: false, message: "Missing 'storeId' query parameter." }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    let threshold = 10;
    if (thresholdParam) {
      const parsed = parseInt(thresholdParam, 10);
      if (isNaN(parsed)) {
        return new Response(
          JSON.stringify({ success: false, message: "Invalid 'threshold' value. Must be a number." }),
          { status: 400, headers: { "Content-Type": "application/json" } }
        );
      }
      threshold = parsed;
    }

    try {
      const result = await ctx.runQuery(api.products.checkStockAlert, {
        storeId,
        threshold,
      });

      return new Response(JSON.stringify(result), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (error) {
      return new Response(
        JSON.stringify({ success: false, message: (error instanceof Error ? error.message : String(error)) }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }
  }),
});


// GET all orders
http.route({
  path: "/app/orders/get/all",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const orders = await ctx.runQuery(api.orders.getAllOrders);
    return new Response(JSON.stringify(orders), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});

// GET all Successful Payment Orders
http.route({
  path: "/app/orders/get/all/successful-payment",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const orders = await ctx.runQuery(api.orders.getAllSuccessfulPaymentOrders, {});
    return new Response(JSON.stringify(orders), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});


// Get accepted orders
http.route({
  path: "/app/orders/get/accepted",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const orders = await ctx.runQuery(api.orders.getAcceptedOrders);
    return new Response(JSON.stringify(orders), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});

// Get rejected orders
http.route({
  path: "/app/orders/get/rejected",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const orders = await ctx.runQuery(api.orders.getRejectedOrders);
    return new Response(JSON.stringify(orders), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});


// Accept order
http.route({
  path: "/app/orders/accept",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const { id } = await req.json();
    const result = await ctx.runMutation(api.orders.acceptOrder, { id });
    return new Response(JSON.stringify(result), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});

// Reject order
http.route({
  path: "/app/orders/reject",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const { id } = await req.json();
    const result = await ctx.runMutation(api.orders.rejectOrder, { id });
    return new Response(JSON.stringify(result), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});


// Send message (admin → Single user)
http.route({
  path: "/app/messages/send/user",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const { userId, content } = await req.json();
    const result = await ctx.runMutation(api.messages.sendMessageToUser, { userId, content });
    return new Response(JSON.stringify(result), { headers: { "Content-Type": "application/json" } });
  }),
});

// Send message (admin → All users)
http.route({
  path: "/app/messages/send/all",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const { content } = await req.json();
    const result = await ctx.runMutation(api.messages.sendMessageToAll, { content });
    return new Response(JSON.stringify(result), { headers: { "Content-Type": "application/json" } });
  }),
});

// Get all messages by user
http.route({
  path: "/app/messages/get/all",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const url = new URL(req.url);
    const userId = url.searchParams.get("userId");

    if (!userId) {
      return new Response(JSON.stringify({ message: "Missing userId" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const result = await ctx.runQuery(api.messages.getAllMessagesByUser, { userId });
    return new Response(JSON.stringify(result), { headers: { "Content-Type": "application/json" } });
  }),
});

// Get unread messages by user
http.route({
  path: "/app/messages/get/unread",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const url = new URL(req.url);
    const userId = url.searchParams.get("userId");

    if (!userId) {
      return new Response(JSON.stringify({ message: "Missing userId" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const result = await ctx.runQuery(api.messages.getUnreadMessagesByUser, { userId });
    return new Response(JSON.stringify(result), { headers: { "Content-Type": "application/json" } });
  }),
});

// Get read messages by user
http.route({
  path: "/app/messages/get/read",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const url = new URL(req.url);
    const userId = url.searchParams.get("userId");

    if (!userId) {
      return new Response(JSON.stringify({ message: "Missing userId" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const result = await ctx.runQuery(api.messages.getReadMessagesByUser, { userId });
    return new Response(JSON.stringify(result), { headers: { "Content-Type": "application/json" } });
  }),
});

// Mark message as read
http.route({
  path: "/app/messages/mark-read",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const { id } = await req.json();
    const result = await ctx.runMutation(api.messages.markAsRead, { id });
    return new Response(JSON.stringify(result), { headers: { "Content-Type": "application/json" } });
  }),
});

// GET all customers
http.route({
  path: "/app/customers/get/all",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const customers = await ctx.runQuery(api.customers.getAllCustomers);
    return new Response(JSON.stringify(customers), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});

// Get customer by ID
http.route({
  path: "/app/customers/getByUserId",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const url = new URL(req.url);
    const userId = url.searchParams.get("userId");

    if (!userId) {
      return new Response(
        JSON.stringify({ message: "Missing userId" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const customer = await ctx.runQuery(api.customers.getCustomerByUserId, {
      userId,
    });

    if (!customer) {
      return new Response(
        JSON.stringify({ message: "Customer not found" }),
        { status: 404, headers: { "Content-Type": "application/json" } }
      );
    }

    return new Response(JSON.stringify(customer), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});

// -----------------------------
// API Endpoints for Analytics on Dashboard
// -----------------------------

// Revenue API (sum of totals for delivered orders)
http.route({
  path: "/app/orders/stats/revenue",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const result = await ctx.runQuery(api.orders.getRevenue);
    return new Response(JSON.stringify(result), { headers: { "Content-Type": "application/json" } });
  }),
});

// Number of delivered orders
http.route({
  path: "/app/orders/stats/delivered-count",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const result = await ctx.runQuery(api.orders.getDeliveredOrdersCount);
    return new Response(JSON.stringify(result), { headers: { "Content-Type": "application/json" } });
  }),
});

// New Customers (created within last 2 days)
http.route({
  path: "/app/customers/stats/new",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const result = await ctx.runQuery(api.customers.getNewCustomers);
    return new Response(JSON.stringify(result), { headers: { "Content-Type": "application/json" } });
  }),
});

// Number of refunds (cancelled orders)
http.route({
  path: "/app/orders/stats/refunds",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const result = await ctx.runQuery(api.orders.getRefundsCount);
    return new Response(JSON.stringify(result), { headers: { "Content-Type": "application/json" } });
  }),
});


// Current Orders (confirmed, shipped, delivered counts)
http.route({
  path: "/app/orders/stats/current",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const result = await ctx.runQuery(api.orders.getCurrentOrders);
    return new Response(JSON.stringify(result), { headers: { "Content-Type": "application/json" } });
  }),
});

// GET active customers
http.route({
  path: "/app/customers/get/active",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const result = await ctx.runQuery(api.customers.getActiveCustomers);
    return new Response(JSON.stringify(result), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});


// Get Customer Stats
http.route({
  path: "/app/customers/get/customer-stats",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const stats = await ctx.runQuery(api.customers.getCustomerStats, {});
    return new Response(JSON.stringify(stats), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});


// Get total number of orders
http.route({
  path: "/app/orders/stats/total",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const result = await ctx.runQuery(api.orders.getTotalOrdersCount);
    return new Response(JSON.stringify(result), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});

// Get all orders by userId
http.route({
  path: "/app/orders/get/by-user",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const url = new URL(req.url);
    const userId = url.searchParams.get("userId");

    if (!userId) {
      return new Response(JSON.stringify({ message: "Missing userId" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const result = await ctx.runQuery(api.orders.getOrdersByUserId, { userId });
    return new Response(JSON.stringify(result), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});

// Get total number of orders by userId
http.route({
  path: "/app/orders/stats/by-user",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const url = new URL(req.url);
    const userId = url.searchParams.get("userId");

    if (!userId) {
      return new Response(JSON.stringify({ message: "Missing userId" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const result = await ctx.runQuery(api.orders.getOrdersCountByUserId, { userId });
    return new Response(JSON.stringify(result), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});


// -----------------------------
// Store Endpoints
// -----------------------------


// Update KYC Status
http.route({
  path: "/app/stores/update/kyc-status",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const { id, kycStatus } = await req.json();

    if (!id || !kycStatus) {
      return new Response(
        JSON.stringify({ success: false, message: "Missing id or kycStatus" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const result = await ctx.runMutation(api.stores.updateKycStatus, { id, kycStatus });
    return new Response(JSON.stringify(result), { headers: { "Content-Type": "application/json" } });
  }),
});

// Update Store Status
http.route({
  path: "/app/stores/update/store-status",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const { id, storeStatus } = await req.json();

    if (!id || !storeStatus) {
      return new Response(
        JSON.stringify({ success: false, message: "Missing id or storeStatus" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const result = await ctx.runMutation(api.stores.updateStoreStatus, { id, storeStatus });
    return new Response(JSON.stringify(result), { headers: { "Content-Type": "application/json" } });
  }),
});

// Get Store Stats
http.route({
  path: "/app/stores/stats",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const stats = await ctx.runQuery(api.stores.getStoreStats, {});
    return new Response(JSON.stringify(stats), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});


// -----------------------------
// Store Partners Endpoints
// -----------------------------

// Add a new store partner
http.route({
  path: "/app/store-partners/add",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const body = await req.json();
    const partner = await ctx.runMutation(api.storePartners.addStorePartner, body);
    return new Response(JSON.stringify({ success: true, partner }), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});

// Get all partners for a store
http.route({
  path: "/app/store-partners/get/by-store",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const url = new URL(req.url);
    const storeId = url.searchParams.get("storeId");

    if (!storeId) {
      return new Response(
        JSON.stringify({ success: false, message: "Missing storeId" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const partners = await ctx.runQuery(api.storePartners.getStorePartnersByStore, { storeId });
    return new Response(JSON.stringify({ success: true, partners }), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});


// -----------------------------
// Delivery Agents Endpoints
// -----------------------------

// Assign delivery agent
http.route({
  path: "/app/orders/assign-delivery-agent",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const body = await req.json();
    const result = await ctx.runMutation(api.orders.assignDeliveryAgent, body);
    return new Response(JSON.stringify(result), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});

// GET all agents
http.route({
  path: "/app/agents/get/all",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const agents = await ctx.runQuery(api.deliveryAgents.getAllAgents);
    return new Response(JSON.stringify(agents), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});

// Get agents by status (Online / Offline / Busy)
http.route({
  path: "/app/agents/get/by-status",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const url = new URL(req.url);
    const status = url.searchParams.get("status");

    if (!status) {
      return new Response(
        JSON.stringify({ success: false, message: "Missing status" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const agents = await ctx.runQuery(api.deliveryAgents.getAgentsByStatus, { status });
    return new Response(JSON.stringify({ success: true, agents }), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});

// Get agents by zone
http.route({
  path: "/app/agents/get/by-zone",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const url = new URL(req.url);
    const zone = url.searchParams.get("zone");

    if (!zone) {
      return new Response(
        JSON.stringify({ success: false, message: "Missing zone" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const agents = await ctx.runQuery(api.deliveryAgents.getAgentsByZone, { zone });
    return new Response(JSON.stringify({ success: true, agents }), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});

// Add a new agent
http.route({
  path: "/app/agents/add",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const body = await req.json();
    const result = await ctx.runMutation(api.deliveryAgents.addDeliveryAgent, body);
    return new Response(JSON.stringify(result), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});

// Update agent status
http.route({
  path: "/app/agents/update/status",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const { agentId, status } = await req.json();

    if (!agentId || !status) {
      return new Response(
        JSON.stringify({ success: false, message: "Missing agentId or status" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const result = await ctx.runMutation(api.deliveryAgents.updateAgentStatus, { agentId, status });
    return new Response(JSON.stringify(result), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});

// Update license status
http.route({
  path: "/app/agents/update/license-status",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const { agentId, licenseStatus } = await req.json();

    if (!agentId || !licenseStatus) {
      return new Response(
        JSON.stringify({ success: false, message: "Missing agentId or licenseStatus" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const result = await ctx.runMutation(api.deliveryAgents.updateLicenseStatus, { agentId, licenseStatus });
    return new Response(JSON.stringify(result), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});

// Update performance
http.route({
  path: "/app/agents/update/performance",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const { agentId, deliveries, completionRate, avgDeliveryTime, earnings } = await req.json();

    if (!agentId) {
      return new Response(
        JSON.stringify({ success: false, message: "Missing agentId" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const result = await ctx.runMutation(api.deliveryAgents.updatePerformance, {
      agentId,
      deliveries,
      completionRate,
      avgDeliveryTime,
      earnings,
    });
    return new Response(JSON.stringify(result), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});


// GET agents stats
http.route({
  path: "/app/agents/stats",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const stats = await ctx.runQuery(api.deliveryAgents.getAgentsStats, {});
    return new Response(JSON.stringify(stats), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});


// -----------------------------
// APP BACKEND ENDPOINTS
// -----------------------------


// -------------------- USER --------------------
http.route({
  path: "/user",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const body = await req.json();
  const user = await ctx.runMutation(api.mutations.createUser, body);
    return new Response(JSON.stringify(user), { status: 200 });
  }),
});



http.route({
  path: "/user/fcm",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const body = await req.json();
  const result = await ctx.runMutation(api.mutations.updateFcmToken, body);
    return new Response(JSON.stringify(result), { status: 200 });
  }),
});



// update user details
http.route({
  path: "/user/update",
  method: "PATCH",
  handler: httpAction(async (ctx, req) => {
    try {
      const body = await req.json();

      // Validate required fields
      const { userId, updatedFields } = body;
      if (!userId || !updatedFields) {
        return new Response(
          JSON.stringify({ message: "Missing userId or updatedFields" }),
          { status: 400, headers: { "Content-Type": "application/json" } }
        );
      }

      const result = await ctx.runMutation(api.mutations.updateUserDetail, {
        userId,
        updatedFields,
      });

      return new Response(JSON.stringify(result), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (error) {
      return new Response(JSON.stringify({ message: error.message }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }
  }),
});



http.route({
  path: "/user/getByUserId",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const url = new URL(req.url);
    const userId = url.searchParams.get("userId");

    if (!userId) {
      return new Response(
        JSON.stringify({ message: "Missing userId" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // Assuming you already have a query like api.queries.getCartById
    const user = await ctx.runQuery(api.userDetails.getUserDetails, { userId });

    if (!user) {
      return new Response(
        JSON.stringify({ message: "User details not found" }),
        { status: 404, headers: { "Content-Type": "application/json" } }
      );
    }

    return new Response(JSON.stringify(user), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});


// checks if user exists

export const checkUserExists = http.route({
  path: "/user/ispresent",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const url = new URL(req.url);
    const userId = url.searchParams.get("userId");

    if (!userId) {
      return new Response(
        JSON.stringify({ exists: false, message: "Missing userId" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // Call your query that checks user
    const exists = await ctx.runQuery(api.mutations.isUserPresent, { userId });

    return new Response(
      JSON.stringify({ exists }),
      { headers: { "Content-Type": "application/json" } }
    );
  }),
});


// -------------------- ADDRESS --------------------



// add address
http.route({
  path: "/user/address",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const body = await req.json();
  const result = await ctx.runMutation(api.mutations.addAddress, body);
    return new Response(JSON.stringify(result), { status: 200 });
  }),
});




// ✅ Update Address
http.route({
  path: "/user/address",
  method: "PATCH",
  handler: httpAction(async (ctx, req) => {
    const body = await req.json();
    const result = await ctx.runMutation(api.mutations.updateAddress, body);
    return new Response(JSON.stringify(result), { status: 200 });
  }),
});

// ✅ Remove Address
http.route({
  path: "/user/address",
  method: "DELETE",
  handler: httpAction(async (ctx, req) => {
    const body = await req.json();
    const result = await ctx.runMutation(api.mutations.removeAddress, body);
    return new Response(JSON.stringify(result), { status: 200 });
  }),
});


// --------------------PRODUCT --------------------

// -------------------- GET ALL PRODUCTS WITH PAGINATION --------------------
http.route({
  path: "/products/getAll",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const url = new URL(req.url);

    const limit = Number(url.searchParams.get("limit")) || 10; // default = 10
    const cursor = url.searchParams.get("cursor") || undefined;

    try {
      const products = await ctx.runQuery(api.products.getAllProducts, {
        limit,
        cursor,
      });

      return new Response(JSON.stringify(products), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (error) {
      return new Response(
        JSON.stringify({ message: err.message }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }
  }),
});

// -------------------- GET PRODUCT BY ID --------------------
http.route({
  path: "/products/getById",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const url = new URL(req.url);
    const productId = url.searchParams.get("id"); // products/getById?id=<productId>

    if (!productId) {
      return new Response(
        JSON.stringify({ message: "Missing productId" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    try {
      const product = await ctx.runQuery(api.products.getProductById, {
        id: productId, // pass productId directly, no type assertion in JS
      });

      if (!product) {
        return new Response(
          JSON.stringify({ message: "Product not found" }),
          { status: 404, headers: { "Content-Type": "application/json" } }
        );
      }

      return new Response(JSON.stringify(product), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (error) {
      return new Response(
        JSON.stringify({ message: error.message }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }
  }),
});


// get products by category

http.route({
  path: "/products/getByCategory",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    try {
      const url = new URL(req.url);

      const category = url.searchParams.get("category");
      const tagsParam = url.searchParams.get("tags"); // optional, comma-separated
      const limitParam = url.searchParams.get("limit");
      const cursor = url.searchParams.get("cursor") || undefined;

      if (!category) {
        return new Response(
          JSON.stringify({ message: "Missing category parameter" }),
          { status: 400, headers: { "Content-Type": "application/json" } }
        );
      }

      const limit = limitParam ? Number(limitParam) : 10; // default 10

      const tags = tagsParam
        ? tagsParam.split(",").map(t => t.trim())
        : undefined;

      const result = await ctx.runQuery(api.products.getProductsByCategory, {
        category,
        tags,
        limit,
        cursor,
      });

      return new Response(JSON.stringify(result), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (error) {
      return new Response(
        JSON.stringify({ message: error.message }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }
  }),
});



// -------------------- WISHLIST --------------------

http.route({
  path: "/wishlist",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const body = await req.json();
  const result = await ctx.runMutation(api.mutations.addToWishlist, body);
    return new Response(JSON.stringify(result), { status: 200 });
  }),
});

http.route({
  path: "/wishlist",
  method: "DELETE",
  handler: httpAction(async (ctx, req) => {
    const body = await req.json();
  const result = await ctx.runMutation(api.mutations.removeFromWishlist, body);
    return new Response(JSON.stringify(result), { status: 200 });
  }),
});

http.route({
  path: "/wishlist/getByUserId",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const url = new URL(req.url);
    const userId = url.searchParams.get("userId");

    if (!userId) {
      return new Response(
        JSON.stringify({ message: "Missing userId" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

  const wishlist = await ctx.runQuery(api.wishlist.getWishlistByUserId, { userId });

    if (!wishlist) {
      return new Response(
        JSON.stringify({ message: "No wishlist found for this user" }),
        { status: 404, headers: { "Content-Type": "application/json" } }
      );
    }

    return new Response(JSON.stringify(wishlist), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});


// -------------------- CART --------------------

// -------------------- GET CART BY USER ID (Query Param) --------------------
http.route({
  path: "/cart/getByUserId",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const url = new URL(req.url);
    const userId = url.searchParams.get("userId");

    if (!userId) {
      return new Response(
        JSON.stringify({ message: "Missing userId" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

  const cart = await ctx.runQuery(api.cart.getCartByUserId, { userId });

    if (!cart) {
      return new Response(
        JSON.stringify({ message: "No cart found for this user" }),
        { status: 404, headers: { "Content-Type": "application/json" } }
      );
    }

    return new Response(JSON.stringify(cart), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});


// -------------------- ADD TO CART --------------------

http.route({
  path: "/cart",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const body = await req.json();
  const result = await ctx.runMutation(api.mutations.addToCart, body);
    return new Response(JSON.stringify(result), { status: 200 });
  }),
});

// -------------------- UPDATE CART ITEM --------------------
http.route({
  path: "/cart",
  method: "PATCH",
  handler: httpAction(async (ctx, req) => {
    const body = await req.json();
  const result = await ctx.runMutation(api.mutations.updateCartItem, body);
    return new Response(JSON.stringify(result), { status: 200 });
  }),
});

// -------------------- REMOVE FROM CART --------------------
http.route({
  path: "/cart",
  method: "DELETE",
  handler: httpAction(async (ctx, req) => {
    const body = await req.json();
  const result = await ctx.runMutation(api.mutations.removeFromCart, body);
    return new Response(JSON.stringify(result), { status: 200 });
  }),
});



// -------------------- STORE --------------------

// Get or create default store
http.route({
  path: "/store/default",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    try {
      const storeId = await ctx.runMutation(api.mutations.getOrCreateDefaultStore, {});
      return new Response(JSON.stringify({ storeId }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (error) {
      return new Response(
        JSON.stringify({ message: error.message }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }
  }),
});

// -------------------- ORDER --------------------



// create order from cart
http.route({
  path: "/order",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    try {
      const body = await req.json();
      
      // Validate required fields
      const { userId, addressId, orderId, storeId } = body;
      if (!userId || !addressId || !orderId || !storeId) {
        return new Response(
          JSON.stringify({ 
            message: "Missing required fields: userId, addressId, orderId, storeId" 
          }),
          { status: 400, headers: { "Content-Type": "application/json" } }
        );
      }
      
      const result = await ctx.runMutation(api.orders.createOrderFromCart, body);
      return new Response(JSON.stringify(result), { status: 200 });
    } catch (error) {
      return new Response(
        JSON.stringify({ message: error.message }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }
  }),
});


// update order status
http.route({
  path: "/order/status",
  method: "PATCH",
  handler: httpAction(async (ctx, req) => {
    const body = await req.json();
  const result = await ctx.runMutation(api.mutations.updateOrderStatus, body);
    return new Response(JSON.stringify(result), { status: 200 });
  }),
});



// -------------------- GET ORDERS BY USER ID (Query Param) --------------------

http.route({
  path: "/order/getByUserId",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const url = new URL(req.url);
    const userId = url.searchParams.get("userId");

    if (!userId) {
      return new Response(
        JSON.stringify({ message: "Missing userId" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

  const orders = await ctx.runQuery(api.orders.getOrdersByUserId, { userId });

    if (!orders) {
      return new Response(
        JSON.stringify({ message: "No orders found for this user" }),
        { status: 404, headers: { "Content-Type": "application/json" } }
      );
    }

    return new Response(JSON.stringify(orders), {
      headers: { "Content-Type": "application/json" },
    });
  }),
});


// -------------------- ORDER PAYMENT STATUS --------------------
http.route({
  path: "/order/payment",
  method: "PATCH",
  handler: httpAction(async (ctx, req) => {
    const body = await req.json();
    const result = await ctx.runMutation(api.mutations.updatePaymentStatus, body);
    return new Response(JSON.stringify(result), { status: 200 });
  }),
});

/* 

------- App Delivery Agent Endpoints -------

*/


// get delivery agent details by employeeId
http.route({
  path: "/delivery-agent/details",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    const url = new URL(request.url);
    const employeeId = url.searchParams.get("employeeId");
    if (!employeeId)
      return new Response("employeeId is required", { status: 400 });

    try {
      const result = await ctx.runQuery(api.deliveryAgents.getAgentByEmployeeId, { employeeId });
      return new Response(JSON.stringify(result), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (e) {
      return new Response(JSON.stringify({ error: e.message }), { status: 404 });
    }
  }),
});


// delivery agent login
http.route({
  path: "/delivery-agent/login",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    const body = await request.json();
    const { email, employeeId } = body;
    if (!email || !employeeId)
      return new Response("email and employeeId are required", { status: 400 });

    try {
      const result = await ctx.runQuery(api.deliveryAgents.login, { email, employeeId });
      return new Response(JSON.stringify(result), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (e) {
      return new Response(JSON.stringify({ error: e.message }), { status: 401 });
    }
  }),
});

/*
get delivery agent status 
*/

http.route({
  path: "/delivery-agent/status",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    const url = new URL(request.url);
    const employeeId = url.searchParams.get("employeeId");
    if (!employeeId)
      return new Response("employeeId is required", { status: 400 });

    try {
      const result = await ctx.runQuery(api.deliveryAgents.getAgentStatus, { employeeId });
      return new Response(JSON.stringify(result), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (e) {
      return new Response(JSON.stringify({ error: e.message }), { status: 404 });
    }
  }),
});


/*
update delivery agent status 
*/ 

http.route({
  path: "/delivery-agent/update-status",
  method: "PATCH",
  handler: httpAction(async (ctx, request) => {
    const body = await request.json();
    const { employeeId, status } = body;
    if (!employeeId || !status)
      return new Response("employeeId and status are required", { status: 400 });

    try {
      const result = await ctx.runMutation(api.deliveryAgents.updateAgentStatusApp, { employeeId, status });
      return new Response(JSON.stringify(result), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (e) {
      return new Response(JSON.stringify({ error: e.message }), { status: 400 });
    }
  }),
});



/* ------------------------
   Get license status
------------------------ */
http.route({
  path: "/delivery-agent/license-status",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    const url = new URL(request.url);
    const employeeId = url.searchParams.get("employeeId");

    if (!employeeId)
      return new Response(JSON.stringify({ error: "employeeId is required" }), { status: 400 });

    try {
      const result = await ctx.runQuery(api.deliveryAgents.getLicenseStatus, { employeeId });
      return new Response(JSON.stringify(result), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (e) {
      return new Response(JSON.stringify({ error: e.message }), { status: 404 });
    }
  }),
});

/* ------------------------
   Update license status
------------------------ */
http.route({
  path: "/delivery-agent/update-license-status",
  method: "PATCH",
  handler: httpAction(async (ctx, request) => {
    const body = await request.json();
    const { employeeId, licenseStatus } = body;

    if (!employeeId || !licenseStatus)
      return new Response(JSON.stringify({ error: "employeeId and licenseStatus are required" }), { status: 400 });

    try {
      const result = await ctx.runMutation(api.deliveryAgents.updateLicenseStatusApp, { employeeId, licenseStatus });
      return new Response(JSON.stringify(result), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (e) {
      return new Response(JSON.stringify({ error: e.message }), { status: 400 });
    }
  }),
});


/*
 Get Orders by Delivery Agent by employeeId and agent status with Pagination
*/

http.route({
  path: "/delivery-agent/orders",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    try {
      const url = new URL(request.url);
      const employeeId = url.searchParams.get("employeeId");
      const deliveryAgentStatus = url.searchParams.get("deliveryAgentStatus");
      const limitParam = url.searchParams.get("limit");
      let cursor = url.searchParams.get("cursor") || null;

      if (!employeeId) {
        return new Response(JSON.stringify({ error: "employeeId is required" }), { status: 400 });
      }

      const limit = limitParam ? Number(limitParam) : 10;
      if (cursor === "null" || cursor === "") cursor = null;

      const result = await ctx.runQuery(api.orders.getOrdersByDeliveryAgent, {
        employeeId,
        deliveryAgentStatus,
        limit,
        cursor,
      });

      return new Response(JSON.stringify(result), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    } catch (e) {
      console.error("Error fetching orders:", e);
      return new Response(JSON.stringify({ error: e.message }), { status: 500 });
    }
  }),
});




/* -------------------------
   Update Delivery Agent Status
------------------------- */
http.route({
  path: "/delivery-agent/orders/update-delivery-status",
  method: "PATCH",
  handler: httpAction(async (ctx, request) => {
    const body = await request.json();
    const { orderId, employeeId, deliveryAgentStatus } = body;

    if (!orderId || !employeeId || deliveryAgentStatus === undefined) {
      return new Response(JSON.stringify({ error: "orderId, employeeId, and deliveryAgentStatus are required" }), { status: 400 });
    }

    try {
      const result = await ctx.runMutation(api.orders.updateDeliveryAgentStatus, {
        orderId,
        employeeId,
        deliveryAgentStatus,
      });
      return new Response(JSON.stringify(result), { status: 200, headers: { "Content-Type": "application/json" } });
    } catch (e) {
      return new Response(JSON.stringify({ error: e.message }), { status: 400 });
    }
  }),
});

/* -------------------------
   Update Payment Status
------------------------- */
http.route({
  path: "/delivery-agent/orders/update-payment-status",
  method: "PATCH",
  handler: httpAction(async (ctx, request) => {
    const body = await request.json();
    const { orderId, employeeId, paymentStatus } = body;

    if (!orderId || !employeeId || paymentStatus === undefined) {
      return new Response(JSON.stringify({ error: "orderId, employeeId, and paymentStatus are required" }), { status: 400 });
    }

    try {
      const result = await ctx.runMutation(api.orders.updatePaymentStatus, {
        orderId,
        employeeId,
        paymentStatus,
      });
      return new Response(JSON.stringify(result), { status: 200, headers: { "Content-Type": "application/json" } });
    } catch (e) {
      return new Response(JSON.stringify({ error: e.message }), { status: 400 });
    }
  }),
});

/* -------------------------
   Update Order Status
------------------------- */
http.route({
  path: "/delivery-agent/orders/update-order-status",
  method: "PATCH",
  handler: httpAction(async (ctx, request) => {
    const body = await request.json();
    const { orderId, employeeId, orderStatus } = body;

    if (!orderId || !employeeId || orderStatus === undefined) {
      return new Response(JSON.stringify({ error: "orderId, employeeId, and orderStatus are required" }), { status: 400 });
    }

    try {
      const result = await ctx.runMutation(api.orders.updateOrderStatus, {
        orderId,
        employeeId,
        orderStatus,
      });
      return new Response(JSON.stringify(result), { status: 200, headers: { "Content-Type": "application/json" } });
    } catch (e) {
      return new Response(JSON.stringify({ error: e.message }), { status: 400 });
    }
  }),
});



export default http;
