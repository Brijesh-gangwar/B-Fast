import { v } from "convex/values";
import {
  internalQuery,
  internalMutation,
  internalAction,
} from "./_generated/server";
import { internal } from "./_generated/api";

// Example query (read-only)
export const myQuery = internalQuery({
  args: {
    first: v.number(),
    second: v.string(),
  },
  handler: async (ctx, args) => {
    console.log("Query args:", args.first, args.second);
    return args.first;
  },
});

// Example mutation (read/write)
export const myMutation = internalMutation({
  args: {
    first: v.number(),
    second: v.string(),
  },
  handler: async (ctx, args) => {
    console.log("Mutation args:", args.first, args.second);
    // Example insert into a table called "messages"
    // const id = await ctx.db.insert("messages", { text: args.second, number: args.first });
    return args;
  },
});

// Example action (can call APIs, queries, mutations)
export const myAction = internalAction({
  args: {
    first: v.number(),
    second: v.string(),
  },
  handler: async (ctx, args) => {
    // Call the query
    const data = await ctx.runQuery(internal.myFunctions.myQuery, {
      first: args.first,
      second: args.second,
    });
    console.log("Query result in action:", data);

    // Call the mutation
    await ctx.runMutation(internal.myFunctions.myMutation, {
      first: args.first,
      second: args.second,
    });
  },
});
