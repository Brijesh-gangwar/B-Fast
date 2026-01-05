// convex/products.js
import { mutation, query } from "./_generated/server.js";
import { v } from "convex/values";

// Add Product
export const addProduct = mutation({
  args: {
    storeId: v.id("stores"),
    name: v.string(),
    color: v.string(),
    category: v.string(),
    size: v.array(v.string()),
    subCategory: v.string(),
    price: v.array(v.number()),
    availability: v.array(v.string({ enum: ["Available", "Not Available"] })), // "available" | "Not available"
    fit: v.string(),
    fabric: v.string(),
    sustainable: v.string(),
    materialCare: v.string(),
    details: v.string(),
    tags: v.array(v.string()),
    description: v.string(),
    quantity: v.array(v.number()),
    status: v.optional(v.string({ enum: ["Active", "Out of Stock"] })),
    images: v.optional(
      v.array(
        v.object({
          url: v.string(),
          public_id: v.string(),
        })
      )
    ),
  },
  handler: async (ctx, args) => {
    const productId = await ctx.db.insert("products", {
      ...args,
      status: args.status || "Active", // default
    });
    return { status: "ok", productId };
  },
});

export const addMultipleProducts = mutation({
  args: v.object({
    products: v.array(
      v.object({
        storeId: v.id("stores"),
        name: v.string(),
        color: v.string(),
        category: v.string(),
        size: v.array(v.string()),
        subCategory: v.string(),
        price: v.array(v.number()),
        availability: v.array(v.string({ enum: ["Available", "Not Available"] })),
        fit: v.string(),
        fabric: v.string(),
        sustainable: v.string(),
        materialCare: v.string(),
        details: v.string(),
        tags: v.array(v.string()),
        description: v.string(),
        quantity: v.array(v.number()),
        status: v.optional(v.string({ enum: ["Active", "Out of Stock"] })),
        images: v.optional(
          v.array(
            v.object({
              url: v.string(),
              public_id: v.string(),
            })
          )
        ),
      })
    ),
  }),
  handler: async (ctx, { products }) => {
    const insertedProducts = [];
    for (const product of products) {
      const productId = await ctx.db.insert("products", {
        ...product,
        status: product.status || "Active",
      });
      insertedProducts.push({ ...product, productId });
    }
    return { status: "ok", insertedProducts };
  },
});

export const addProductWithImages = mutation({
  args: {
    storeId: v.id("stores"),
    name: v.string(),
    color: v.string(),
    category: v.string(),
    size: v.array(v.string()),
    subCategory: v.string(),
    price: v.array(v.number()),
    availability: v.array(v.string({ enum: ["Available", "Not Available"] })),
    fit: v.string(),
    fabric: v.string(),
    sustainable: v.string(),
    materialCare: v.string(),
    details: v.string(),
    tags: v.array(v.string()),
    description: v.string(),
    quantity: v.array(v.number()),
    status: v.optional(v.string({ enum: ["Active", "Out of Stock", "Discontinued"] })),
    images: v.optional(
      v.array(
        v.object({
          url: v.string(),
          public_id: v.string(),
        })
      )
    ),
  },

  handler: async (ctx, args) => {
    const productId = await ctx.db.insert("products", {
      ...args,
      status: args.status || "Active",
    });

    return { status: "ok", message: "Product with images added", productId };
  },
});

// Get all products
export const getAllProductsWeb = query({
  args: { storeId: v.optional(v.id("stores")) },
  handler: async (ctx, { storeId }) => {
    let q = ctx.db.query("products");
    if (storeId) {
      q = q.withIndex("by_storeId", (q) => q.eq("storeId", storeId));
    }
    return await q.collect();
  },
});

// Get Single Product by ID
export const getProductByIdWeb = query({
  args: { id: v.id("products") },
  handler: async (ctx, { id }) => {
    return await ctx.db.get(id);
  },
});

// Edit Product
export const editProduct = mutation({
  args: {
    id: v.id("products"),
    updates: v.object({
      name: v.optional(v.string()),
      color: v.optional(v.string()),
      category: v.optional(v.string()),
      size: v.optional(v.array(v.string())),
      subCategory: v.optional(v.string()),
      price: v.optional(v.array(v.number())),
      availability: v.optional(v.array(v.string({ enum: ["Available", "Not Available"] }))), // "available" | "Not available"
      fit: v.optional(v.string()),
      fabric: v.optional(v.string()),
      sustainable: v.optional(v.string()),
      materialCare: v.optional(v.string()),
      details: v.optional(v.string()),
      tags: v.optional(v.array(v.string())),
      description: v.optional(v.string()),
      quantity: v.array(v.number()),
      status: v.optional(v.string({ enum: ["Active", "Out of Stock"] })),
      images: v.optional(
        v.array(
          v.object({
            url: v.string(),
            public_id: v.string(),
          })
        )
      ),
    }),
  },
  handler: async (ctx, { id, updates }) => {
    await ctx.db.patch(id, updates);
    return { status: "updated" };
  },
});

// Delete Product
export const deleteProduct = mutation({
  args: { id: v.id("products") },
  handler: async (ctx, { id }) => {
    await ctx.db.delete(id);
    return { status: "deleted" };
  }
});

// Upload/Update product images
export const updateProductImages = mutation({
  args: {
    id: v.id("products"),
    images: v.array(
      v.object({
        url: v.string(),
        public_id: v.string(),
      })
    ),
  },
  handler: async (ctx, { id, images }) => {
    await ctx.db.patch(id, { images });
    return { status: "images updated" };
  },
});

// Query function to check stock alerts
export const checkStockAlert = query({
  args: {
    storeId: v.id("stores"),
    threshold: v.optional(v.number()),
  },
  handler: async (ctx, { storeId, threshold = 10 }) => {
    // Fetch all products belonging to the given store
    const products = await ctx.db
      .query("products")
      .withIndex("by_storeId", (q) => q.eq("storeId", storeId))
      .collect();

    // Filter products whose total quantity <= threshold
    const lowStockProducts = products.filter((product) => {
      if (!product.quantity || product.quantity.length === 0) return false;
      const totalQuantity = product.quantity.reduce((a, b) => a + b, 0);
      return totalQuantity <= threshold;
    });

    return {
      success: true,
      storeId,
      threshold,
      count: lowStockProducts.length,
      products: lowStockProducts.map((p) => ({
        id: p._id,
        name: p.name,
        totalQuantity: p.quantity.reduce((a, b) => a + b, 0),
        status: p.status,
      })),
    };
  },
});

// Get products Added in last X days
export const getProductsByDays = query({
  args: { days: v.number() },
  handler: async (ctx, { days }) => {
    const now = Date.now();
    const cutoff = now - days * 24 * 60 * 60 * 1000;

    return await ctx.db
      .query("products")
      .filter(q => q.gte(q.field("_creationTime"), cutoff))
      .collect();
  },
});

//  Mark Product Status as (Active / Out of Stock / Discontinued)
export const updateProductStatus = mutation({
  args: { 
    id: v.id("products"), 
    status: v.string({ enum: ["Active", "Out of Stock", "Discontinued"] }) 
  },
  handler: async (ctx, { id, status }) => {
    const product = await ctx.db.get(id);
    if (!product) {
      throw new Error("Product not found");
    }

    await ctx.db.patch(id, { status });
    return { 
      status: "success", 
      productId: id, 
      message: `Product marked as ${status}` 
    };
  },
});


// -----------------------------
// APP Backend APIs
// -----------------------------

// Simple Pagination for Products
export const getAllProducts = query({
  args: {
    limit: v.number(),               // how many items per page
    cursor: v.optional(v.string()),  // continuation cursor
  },
  handler: async (ctx, args) => {
    const { limit, cursor } = args;

    const result = await ctx.db.query("products").paginate({
      numItems: limit,
      cursor: cursor ?? null,
    });

    // For each product, fetch minimal store details
    const productsWithStore = await Promise.all(
      result.page.map(async (product) => {
        const store = await ctx.db.get(product.storeId);
        return {
          productId: product._id,
          name: product.name,
          color: product.color,
          size: product.size,
          price: product.price,
          category: product.category,
          subCategory: product.subCategory,
          availability: product.availability,
          fit: product.fit,
          fabric: product.fabric,
          sustainable: product.sustainable,
          materialCare: product.materialCare,
          details: product.details,
          tags: product.tags,
          description: product.description,
          status: product.status,
          images: product.images,
          store: store
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
      page: productsWithStore,
      isDone: result.isDone,
      continueCursor: result.continueCursor,
    };
  },
});




export const getProductById = query({
  args: { id: v.id("products") },
  handler: async (ctx, { id }) => {
    const product = await ctx.db.get(id);
    if (!product) return null;

    // Fetch the store details
    const store = await ctx.db.get(product.storeId);

    return {
      ...product,
      store: store
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
  },
});


export const getProductsByCategory = query({
  args: {
    category: v.string(),
    tags: v.optional(v.array(v.string())), // optional array of tags
    limit: v.number(),
    cursor: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const { category, tags, limit, cursor } = args;

    // Correct filter syntax using predicate function
    const result = await ctx.db.query("products")
      .filter(q => q.eq(q.field("category"), category))
      .paginate({
        numItems: limit,
        cursor: cursor ?? null,
      });

    // Filter by tags (AND logic)
    let filteredProducts = result.page;
    if (tags && tags.length > 0) {
      filteredProducts = filteredProducts.filter(product => {
        if (!product.tags || !Array.isArray(product.tags)) return false;
        const productTags = product.tags.map(t => t.toLowerCase());
        return tags.every(tag => productTags.includes(tag.toLowerCase()));
      });
    }

    // Fetch store info for each product
    const productsWithStore = await Promise.all(
      filteredProducts.map(async (product) => {
        const store = await ctx.db.get(product.storeId);
        return {
          productId: product._id,
          name: product.name,
          color: product.color,
          size: product.size,
          price: product.price,
          category: product.category,
          subCategory: product.subCategory,
          availability: product.availability,
          fit: product.fit,
          fabric: product.fabric,
          sustainable: product.sustainable,
          materialCare: product.materialCare,
          details: product.details,
          tags: product.tags,
          description: product.description,
          status: product.status,
          images: product.images,
          store: store
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
      page: productsWithStore,
      isDone: result.isDone,
      continueCursor: result.continueCursor,
    };
  },
});
