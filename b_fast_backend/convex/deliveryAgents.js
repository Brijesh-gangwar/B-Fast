import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

// Add New Delivery Agent
export const addDeliveryAgent = mutation({
  args: {
    fullName: v.string(),
    email: v.string(),
    phone: v.string(),
    employeeId: v.string(),
    rating: v.float64(),
    zone: v.string(),
    deliveries: v.number(),
    completionRate: v.float64(),
    avgDeliveryTime: v.string(),
    earnings: v.float64(),
    vehicleType: v.string(),
    licenseStatus: v.string({ enum: ["Pending", "Verified", "Rejected"] }),
    status: v.string({ enum: ["Online", "Offline", "Busy"] }),
    createdAt: v.string(),
  },
  handler: async (ctx, args) => {
    await ctx.db.insert("deliveryAgents", args);
    return { success: true, message: "Delivery agent added successfully" };
  },
});

// Update Agent Status (Online/Offline/Busy)
export const updateAgentStatus = mutation({
  args: {
    agentId: v.id("deliveryAgents"),
    status: v.string({ enum: ["Online", "Offline", "Busy"] }),
  },
  handler: async (ctx, { agentId, status }) => {
    await ctx.db.patch(agentId, { status, updatedAt: new Date().toISOString() });
    return { success: true, message: `Agent status updated to ${status}` };
  },
});

// Update License Verification
export const updateLicenseStatus = mutation({
  args: {
    agentId: v.id("deliveryAgents"),
    licenseStatus: v.string({ enum: ["Pending", "Verified", "Rejected"] }),
  },
  handler: async (ctx, { agentId, licenseStatus }) => {
    await ctx.db.patch(agentId, { licenseStatus, updatedAt: new Date().toISOString() });
    return { success: true, message: `License status updated to ${licenseStatus}` };
  },
});

// Update Performance (deliveries, earnings, etc.)
export const updatePerformance = mutation({
  args: {
    agentId: v.id("deliveryAgents"),
    deliveries: v.number(),
    completionRate: v.float64(),
    avgDeliveryTime: v.string(),
    earnings: v.float64(),
  },
  handler: async (ctx, { agentId, deliveries, completionRate, avgDeliveryTime, earnings }) => {
    await ctx.db.patch(agentId, {
      deliveries,
      completionRate,
      avgDeliveryTime,
      earnings,
      updatedAt: new Date().toISOString(),
    });
    return { success: true, message: "Performance updated successfully" };
  },
});

// Get All Agents
export const getAllAgents = query({
  args: {},
  handler: async (ctx) => {
    return await ctx.db.query("deliveryAgents").collect();
  },
});

// Get Agents By Status
export const getAgentsByStatus = query({
  args: { status: v.string({ enum: ["Online", "Offline", "Busy"] }) },
  handler: async (ctx, { status }) => {
    return await ctx.db
      .query("deliveryAgents")
      .filter((q) => q.eq(q.field("status"), status))
      .collect();
  },
});

// Get Agents By Zone
export const getAgentsByZone = query({
  args: { zone: v.string() },
  handler: async (ctx, { zone }) => {
    return await ctx.db
      .query("deliveryAgents")
      .filter((q) => q.eq(q.field("zone"), zone))
      .collect();
  },
});

// GET Agents Stats
export const getAgentsStats = query({
  args: {},
  handler: async (ctx) => {
    const agents = await ctx.db.query("deliveryAgents").collect();

    if (agents.length === 0) {
      return {
        totalAgents: 0,
        totalOnline: 0,
        avgRating: 0,
        avgDeliveryTime: 0,
      };
    }

    const totalAgents = agents.length;
    const totalOnline = agents.filter((a) => a.status === "Online").length;

    const avgRating =
      agents.reduce((sum, a) => sum + (a.rating || 0), 0) / totalAgents;

    // avgDeliveryTime is stored as string ("22 min") → parse to number
    const avgDeliveryTime =
      agents.reduce((sum, a) => {
        const num = parseInt(a.avgDeliveryTime); // extracts minutes
        return sum + (isNaN(num) ? 0 : num);
      }, 0) / totalAgents;

    return {
      totalAgents,
      totalOnline,
      avgRating: parseFloat(avgRating.toFixed(2)),
      avgDeliveryTime: parseFloat(avgDeliveryTime.toFixed(2)),
    };
  },
});


//  ----- app functions for delivery agents -----


// get agent by employeeId
export const getAgentByEmployeeId = query(async (ctx, { employeeId }) => {
  const agent = await ctx.db
    .query("deliveryAgents")
    .filter((q) => q.eq(q.field("employeeId"), employeeId))
    .first();

  if (!agent) throw new Error("Agent not found");
  return agent;
});


// 📘 QUERY: Agent login
export const login = query(async (ctx, { email, employeeId }) => {
  const agent = await ctx.db
    .query("deliveryAgents")
    .filter((q) => q.eq(q.field("employeeId"), employeeId))
    .filter((q) => q.eq(q.field("email"), email))
    .first();

  if (!agent) throw new Error("Invalid credentials");

  return {
    success: true,
    employeeId: agent.employeeId,
    status: agent.status,
    licenseStatus: agent.licenseStatus,
  };
});

  // 📘 QUERY: Get agent status by employeeId

export const getAgentStatus = query(async (ctx, { employeeId }) => {
  const agent = await ctx.db
    .query("deliveryAgents")
    .filter((q) => q.eq(q.field("employeeId"), employeeId))
    .first();

  if (!agent) throw new Error("Agent not found");
  return { employeeId: agent.employeeId, status: agent.status };
});

/* --------------------------------------------------
   🧩 MUTATION: Update agent status
-------------------------------------------------- */
export const updateAgentStatusApp = mutation(async (ctx, { employeeId, status }) => {
  const agent = await ctx.db
    .query("deliveryAgents")
    .filter((q) => q.eq(q.field("employeeId"), employeeId))
    .first();

  if (!agent) throw new Error("Agent not found");

  await ctx.db.patch(agent._id, { status, updatedAt: new Date().toISOString() });
  return { success: true, message: "Status updated successfully", status };
});



/* --------------------------------------------------
   Get license status by employeeId
-------------------------------------------------- */
export const getLicenseStatus = query(async (ctx, { employeeId }) => {
  const agent = await ctx.db
    .query("deliveryAgents")
    .filter((q) => q.eq(q.field("employeeId"), employeeId))
    .first();

  if (!agent) throw new Error("Agent not found");
  return { employeeId: agent.employeeId, licenseStatus: agent.licenseStatus };
});

/* --------------------------------------------------
   Update license status
-------------------------------------------------- */
export const updateLicenseStatusApp = mutation(async (ctx, { employeeId, licenseStatus }) => {
  const validStatuses = ["Pending", "Verified", "Rejected"];
  if (!validStatuses.includes(licenseStatus)) {
    throw new Error("Invalid licenseStatus value");
  }

  const agent = await ctx.db
    .query("deliveryAgents")
    .filter((q) => q.eq(q.field("employeeId"), employeeId))
    .first();

  if (!agent) throw new Error("Agent not found");

  await ctx.db.patch(agent._id, {
    licenseStatus,
    updatedAt: new Date().toISOString(),
  });

  return { success: true, licenseStatus };
});

