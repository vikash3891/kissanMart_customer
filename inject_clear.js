const fs = require('fs');
const path = require('path');

const providers = [
  { name: 'address', props: `_addresses = []; _selectedAddress = null; _error = null; notifyListeners();` },
  { name: 'cart', props: `_items = []; _error = null; notifyListeners();` },
  { name: 'order', props: `_orders = []; _selectedOrder = null; _error = null; notifyListeners();` },
  { name: 'profile', props: `_profile = null; _error = null; notifyListeners();` },
  { name: 'wishlist', props: `_wishlist = []; _error = null; notifyListeners();` },
  { name: 'notification', props: `_notifications = []; _unreadCount = 0; notifyListeners();` }
];

providers.forEach(p => {
  const filePath = path.join(__dirname, 'lib', 'providers', `${p.name}_provider.dart`);
  if (fs.existsSync(filePath)) {
    let content = fs.readFileSync(filePath, 'utf8');
    // Find the last closing brace
    const lastBraceIndex = content.lastIndexOf('}');
    if (lastBraceIndex !== -1) {
      const clearMethod = `\n  void clear() {\n    ${p.props}\n  }\n`;
      content = content.substring(0, lastBraceIndex) + clearMethod + content.substring(lastBraceIndex);
      fs.writeFileSync(filePath, content);
      console.log(`Updated ${p.name}_provider.dart`);
    }
  } else {
    console.log(`File not found: ${filePath}`);
  }
});
