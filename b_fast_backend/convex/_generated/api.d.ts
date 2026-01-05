/* eslint-disable */
/**
 * Generated `api` utility.
 *
 * THIS CODE IS AUTOMATICALLY GENERATED.
 *
 * To regenerate, run `npx convex dev`.
 * @module
 */

import type * as cart from "../cart.js";
import type * as customers from "../customers.js";
import type * as deliveryAgents from "../deliveryAgents.js";
import type * as http from "../http.js";
import type * as messages from "../messages.js";
import type * as mutations from "../mutations.js";
import type * as myFunctions from "../myFunctions.js";
import type * as orders from "../orders.js";
import type * as products from "../products.js";
import type * as storePartners from "../storePartners.js";
import type * as stores from "../stores.js";
import type * as userDetails from "../userDetails.js";
import type * as wishlist from "../wishlist.js";

import type {
  ApiFromModules,
  FilterApi,
  FunctionReference,
} from "convex/server";

declare const fullApi: ApiFromModules<{
  cart: typeof cart;
  customers: typeof customers;
  deliveryAgents: typeof deliveryAgents;
  http: typeof http;
  messages: typeof messages;
  mutations: typeof mutations;
  myFunctions: typeof myFunctions;
  orders: typeof orders;
  products: typeof products;
  storePartners: typeof storePartners;
  stores: typeof stores;
  userDetails: typeof userDetails;
  wishlist: typeof wishlist;
}>;

/**
 * A utility for referencing Convex functions in your app's public API.
 *
 * Usage:
 * ```js
 * const myFunctionReference = api.myModule.myFunction;
 * ```
 */
export declare const api: FilterApi<
  typeof fullApi,
  FunctionReference<any, "public">
>;

/**
 * A utility for referencing Convex functions in your app's internal API.
 *
 * Usage:
 * ```js
 * const myFunctionReference = internal.myModule.myFunction;
 * ```
 */
export declare const internal: FilterApi<
  typeof fullApi,
  FunctionReference<any, "internal">
>;

export declare const components: {};
