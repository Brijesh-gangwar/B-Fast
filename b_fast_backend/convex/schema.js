import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  // Stores to be added by admin
  stores: defineTable({
    storeName: v.string(),
    description: v.string(),
    category: v.string(),
    tags: v.array(v.string()),
    address: v.object({
      street: v.string(),
      city: v.string(),
      state: v.string(),
      country: v.string(),
      zip: v.string(),
    }),
    contact: v.object({
      phone: v.string(),
      email: v.string(),
    }),
    settings: v.object({
      status: v.boolean(),
      storeType: v.string(),
      businessType: v.string(),
    }),
    owner: v.object({
      fullName: v.string(),
      phone: v.string(),
      email: v.string(),
    }),
    kycStatus: v.string({ enum: ["Pending", "Verified", "Rejected"] }),
    storeStatus: v.string({ enum: ["Active", "Inactive", "Suspended"] }),
    media: v.optional(
      v.object({
        logo: v.optional(
          v.object({
            url: v.string(),
            public_id: v.string(),
          })
        ),
        poster: v.optional(
          v.array(
            v.object({
              url: v.string(),
              public_id: v.string(),
            })
          )
        ),
        gallery: v.optional(
          v.array(
            v.object({
              url: v.string(),
              public_id: v.string(),
            })
          )
        ),
      })
    ),
    createdAt: v.number(),
    updatedAt: v.optional(v.number()),
  }).index("by_storeName", ["storeName"]),

  // Store Partners
  storePartners: defineTable({
    storeId: v.id("stores"), // Reference to the store 
    partnerName: v.string(),
    role: v.string(),
    email: v.string(),
    phone: v.string(),
    joinedAt: v.string(),
    status: v.string({ enum: ["Active", "Inactive"] }),
  }).index("by_storeId", ["storeId"]),

  // Products available in the store
  products: defineTable({
    storeId: v.id("stores"),
    name: v.string(),
    color: v.string(),
    category: v.string(), // -> Convert it to enum later as Men Women Kids etc
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
    status: v.string({ enum: ["Active", "Out of Stock", "Discontinued"] }),
    images: v.optional(v.array(
      v.object({
        url: v.string(),
        public_id: v.string(),
      })
    ))
  }).index("by_storeId", ["storeId"]),

  // Registered users / customers
  userDetails: defineTable({
    userId: v.string(), // Clerk Auth ID
    name: v.string(),
    email: v.string(),
    phone: v.optional(v.string()),
    fcmToken: v.optional(v.string()),
    userStatus: v.string({ enum: ["Active", "Inactive", "Banned"] }),
    addresses: v.array(
      v.object({
        addressId: v.string(),
        label: v.string(),
        street: v.string(),
        city: v.string(),
        state: v.string(),
        zip: v.string(),
        country: v.string(),
        latitude: v.optional(v.string()),
        longitude: v.optional(v.string()),
      })
    ),
  }).index("by_userId", ["userId"]),
  
  // Orders placed by customers
  orders: defineTable({
    storeId: v.id("stores"),
    orderId: v.string(), // client-provided
    userId: v.string(),
    items: v.array(
      v.object({
        productId: v.id("products"),
        name: v.string(),
        price: v.number(),
        quantity: v.number(),
        size: v.string(),
        color: v.string(),
        category: v.string(),
        subCategory: v.string(),
        image: v.optional(v.string()),
      })
    ),
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
    total: v.number(),
    taxes: v.number(),        
    deliveryFee: v.number(),
    
    deliveryAgent: v.optional(v.string({ default: "N/A" })), // delivery agent name or ID
    deliveryAgentStatus: v.optional(v.string({ enum: ["N/A", "Not assigned", "Assigning", "Assigned","Delivered","Delivering"], default: "N/A" })),
    deliveryMode: v.optional(v.string({ default: "N/A" })),  // "Standard" | "Express" | "N/A"
    estimatedTime: v.optional(v.string({ default: "N/A" })), // e.g., "30-45 mins" or "N/A"
    instructions: v.optional(v.string()),

    paymentId: v.optional(v.string()), 
    paymentMethod: v.optional(v.string()), // optional
    paymentStatus: v.string({ enum: ["Pending", "Paid", "Failed"] }),
    orderStatus: v.string({ enum: ["Pending", "Confirmed", "Shipped", "Delivered", "Cancelled"] }),
    createdAt: v.number(),
    updatedAt: v.optional(v.number()),
  }).index("by_userId", ["userId"]).index("by_deliveryAgent", ["deliveryAgent", "deliveryAgentStatus"]).index("by_storeId", ["storeId"]),

  deliveryAgents: defineTable({
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
    updatedAt: v.optional(v.string()),
  }).index("by_employeeId", ["employeeId"]),

  // Messages (Admin → User)
  messages: defineTable({
    userId: v.optional(v.string()), // Which user receives it
    content: v.string(), // The announcement text
    read: v.boolean(), // track if user has seen it
    store: v.optional(v.string()), // Store in which user logs in
    createdAt: v.number(),    // timestamp
  }).index("by_userId", ["userId"]),

    // Wishlist - users APP
  wishlist: defineTable({
    userId: v.string(),
    productId: v.id("products"),
    createdAt: v.number(),
  }).index("by_userId", ["userId"]),

    // Cart - users APP
  cart: defineTable({
    userId: v.string(),
    productId: v.id("products"),
    quantity: v.number(),     
    optionIndex: v.number(),  
    colorIndex: v.number(), 
    addedAt: v.number(),
  }).index("by_userId", ["userId"]),
});
