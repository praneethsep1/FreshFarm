const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Send notification to farmer when a new order is placed
exports.notifyFarmerOnOrder = functions.firestore
  .document('orders/{orderId}')
  .onCreate(async (snap, context) => {
    const orderData = snap.data();
    const items = orderData.items;

    // Get unique farmer IDs from items
    const farmerIds = [...new Set(items.map(item => item.farmerId))];

    for (const farmerId of farmerIds) {
      const farmerDoc = await admin.firestore().collection('users').doc(farmerId).get();
      const farmerToken = farmerDoc.data()?.fcmToken;

      if (farmerToken) {
        const payload = {
          notification: {
            title: 'New Order Received',
            body: `Order #${orderData.orderId} includes your products!`,
          },
          data: {
            type: 'order_placed',
            orderId: orderData.orderId,
          },
          token: farmerToken,
        };

        await admin.messaging().send(payload);
      }
    }
  });

// Send notification to consumer when order status changes
exports.notifyConsumerOnStatusChange = functions.firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();

    if (newData.status !== oldData.status) {
      const userId = newData.userId;
      const userDoc = await admin.firestore().collection('users').doc(userId).get();
      const userToken = userDoc.data()?.fcmToken;

      if (userToken) {
        const payload = {
          notification: {
            title: 'Order Status Updated',
            body: `Your order #${newData.orderId} is now ${newData.status}`,
          },
          data: {
            type: 'order_status',
            orderId: newData.orderId,
          },
          token: userToken,
        };

        await admin.messaging().send(payload);
      }
    }
  });