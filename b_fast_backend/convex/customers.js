import { query } from "./_generated/server.js";
import { v } from "convex/values";

// Get all customers
export const getAllCustomers = query(async (ctx) => {
    return await ctx.db.query("userDetails").collect();
});

// Get user by userId (custom field, not Convex _id)
export const getCustomerByUserId = query({
  args: { userId: v.string() },
  handler: async (ctx, args) => {
    const customers = await ctx.db.query("userDetails").collect();
    return customers.find(c => c.userId === args.userId) || null;
  },
});


// Analytics for Dashboard

// Get total number of customers
export const getTotalCustomers = query({
  args: {},
  handler: async (ctx) => {
    const customers = await ctx.db.query("userDetails").collect();
    return { count: customers.length };
  },
});

// New Customers (registered within last 2 days)
export const getNewCustomers = query({
  args: {},
  handler: async (ctx) => {
    const now = Date.now();
    const twoDaysAgo = now - 2 * 24 * 60 * 60 * 1000; // 2 days in ms

    const customers = await ctx.db.query("userDetails").collect();
    const newCustomers = customers.filter(
      (c) => c._creationTime && c._creationTime >= twoDaysAgo
    );

    return { count: newCustomers.length, customers: newCustomers };
  },
});


// Get Active Customers
export const getActiveCustomers = query({
  args: {},
  handler: async (ctx) => {
    const customers = await ctx.db.query("userDetails").collect();
    const activeCustomers = customers.filter(c => c.userStatus === "Active");
    return { count: activeCustomers.length, customers: activeCustomers };
  },
});

// Get Customer Statistics for Admin Dashboard
export const getCustomerStats = query({
  args: {},
  handler: async (ctx) => {
    const customers = await ctx.db.query("userDetails").collect();
    const orders = await ctx.db.query("orders").collect();

    const totalCustomers = customers.length;
    const activeCustomers = customers.filter((c) => c.userStatus === "Active").length;

    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1).getTime();
    const newCustomersThisMonth = customers.filter(
      (c) => c._creationTime && c._creationTime >= startOfMonth
    ).length;

    let avgOrderValue = 0;
    if (orders.length > 0) {
      const totalRevenue = orders.reduce((sum, o) => sum + o.total, 0);
      avgOrderValue = totalRevenue / orders.length;
    }

    return {
      totalCustomers,
      activeCustomers,
      newCustomersThisMonth,
      avgOrderValue,
    };
  },
});
