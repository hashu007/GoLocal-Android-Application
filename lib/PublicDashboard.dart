import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ProfilePage.dart';
import 'SignIn.dart';
import 'admin_dashboard.dart';
import 'package:url_launcher/url_launcher.dart';

class PublicDashboard extends StatefulWidget {
  @override
  _PublicDashboardState createState() => _PublicDashboardState();
}

class _PublicDashboardState extends State<PublicDashboard> {
  String selectedCity = "All Cities";
  String searchQuery = "";
  int selectedTab = 0; // 0 = Attractions, 1 = Events

  final List<String> cities = [
    "All Cities",
    "Karachi",
    "Lahore",
    "Islamabad",
    "Faisalabad",
    "Rawalpindi"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Explore $selectedCity",
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlue]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCity,
                  icon: const Icon(Icons.arrow_drop_down, size: 18, color: Colors.white),
                  dropdownColor: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(12),
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  onChanged: (value) {
                    if (value != null) setState(() => selectedCity = value);
                  },
                  items: cities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Row(
                        children: [
                          const Icon(Icons.location_city, size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(city),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),

      drawer: Drawer(
        child: Builder(
          builder: (context) {
            final user = FirebaseAuth.instance.currentUser;

            if (user == null) {
              return ListView(
                children: const [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue),
                    child: Text("No user logged in", style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            }

            // 🔹 Fetch user profile from Firestore
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection("users").doc(user.uid).get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                final name = data["name"] ?? "User";
                final contact = data["email"] ?? user.email ?? "";
                final profileImageUrl = data["imageUrl"];

                return Column(
                  children: [
                    UserAccountsDrawerHeader(
                      decoration: const BoxDecoration(color: Colors.blue),
                      accountName: Text(
                        name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      accountEmail: Text(contact), // 👈 now shows contact/email
                      currentAccountPicture: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: (profileImageUrl != null && profileImageUrl.isNotEmpty)
                            ? NetworkImage(profileImageUrl)
                            : null,
                        child: (profileImageUrl == null || profileImageUrl.isEmpty)
                            ? const Icon(Icons.person, size: 40, color: Colors.blue)
                            : null,
                      ),
                    ),

                    // 📋 Main menu
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.dashboard, color: Colors.blue),
                            title: const Text("Admin Dashboard"),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => AdminDashboard()));
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.person, color: Colors.blue),
                            title: const Text("Profile"),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
                            },
                          ),
                        ],
                      ),
                    ),

                    // 🚪 Logout button
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Signin()));
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                );
              },
            );
          },
        ),
      ),


      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.blue[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // 🔍 Search
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Find things to do...",
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
                onChanged: (val) {
                  setState(() => searchQuery = val.toLowerCase());
                },
              ),
            ),

            // 🔹 Tabs
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text("Attractions"),
                    selected: selectedTab == 0,
                    selectedColor: Colors.blue,
                    labelStyle: TextStyle(
                        color: selectedTab == 0 ? Colors.white : Colors.black),
                    onSelected: (_) => setState(() => selectedTab = 0),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text("Events"),
                    selected: selectedTab == 1,
                    selectedColor: Colors.blue,
                    labelStyle: TextStyle(
                        color: selectedTab == 1 ? Colors.white : Colors.black),
                    onSelected: (_) => setState(() => selectedTab = 1),
                  ),
                ],
              ),
            ),

            // 📋 List of Cards
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: (selectedCity == "All Cities")
                    ? FirebaseFirestore.instance
                    .collection(selectedTab == 0 ? "attractions" : "events")
                    .snapshots()
                    : FirebaseFirestore.instance
                    .collection(selectedTab == 0 ? "attractions" : "events")
                    .where("city", isEqualTo: selectedCity)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final text = selectedTab == 0
                        ? (data["name"]?.toString().toLowerCase() ?? "")
                        : (data["title"]?.toString().toLowerCase() ?? "");
                    return text.contains(searchQuery);
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(child: Text("No data found", style: TextStyle(fontSize: 16, color: Colors.black54)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final id = docs[index].id;
                      String? imageUrl = data["image"] ?? data["imageUrl"];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailPage(
                                    data: data,
                                    type: selectedTab == 0 ? "attractions" : "events",
                                    docId: id,
                                  )));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Rounded image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    height: 180,
                                    width: double.infinity,
                                    color: Colors.grey[300],
                                    child: (imageUrl != null && imageUrl.isNotEmpty)
                                        ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                              SizedBox(height: 8),
                                              Text("Image not available", style: TextStyle(color: Colors.grey)),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                        : Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.image, size: 50, color: Colors.grey),
                                          SizedBox(height: 8),
                                          Text("No Image", style: TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  selectedTab == 0 ? data["name"] ?? "" : data["title"] ?? "",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedTab == 0 ? data["description"] ?? "" : data["date"] ?? "",
                                  style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- DETAIL PAGE --------------------

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String type;
  final String docId;

  const DetailPage({
    super.key,
    required this.data,
    required this.type,
    required this.docId,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final TextEditingController _reviewController = TextEditingController();
  double userRating = 0;

  void submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login required to submit review")),
      );
      return;
    }

    final reviewText = _reviewController.text.trim();
    if (reviewText.isEmpty && userRating == 0) return;

    final parentRef =
    FirebaseFirestore.instance.collection(widget.type).doc(widget.docId);

    // Add review
    await parentRef.collection("reviews").add({
      "user": user.email,
      "review": reviewText,
      "rating": userRating,
      "timestamp": FieldValue.serverTimestamp(),
    });

    // 🔹 Recalculate average rating
    final reviewsSnap = await parentRef.collection("reviews").get();
    double total = 0;
    for (var r in reviewsSnap.docs) {
      total += (r['rating'] as num).toDouble();
    }
    final avg = reviewsSnap.docs.isEmpty ? 0 : total / reviewsSnap.docs.length;

    await parentRef.update({
      "rating": avg,
      "ratingCount": reviewsSnap.docs.length,
    });

    _reviewController.clear();
    setState(() {
      userRating = 0;
    });
  }

  void _openMap(double lat, double lng) async {
    final url =
    Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String? imageUrl = widget.data["image"] ?? widget.data["imageUrl"];

    // Get latitude and longitude
    final double lat = (widget.data["lat"] ?? 0).toDouble();
    final double lng = (widget.data["lng"] ?? 0).toDouble();
    final hasLocation = lat != 0 && lng != 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type == "attractions"
            ? widget.data["name"] ?? ""
            : widget.data["title"] ?? ""),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
          fontFamily: "Poppins",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey[300],
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image,
                              size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Image not available",
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  },
                )
                    : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text("No Image",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              widget.type == "attractions"
                  ? widget.data["name"] ?? ""
                  : widget.data["title"] ?? "",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Description / Date
            Text(
              widget.type == "attractions"
                  ? widget.data["description"] ?? ""
                  : "📅 Date: ${widget.data["date"] ?? ""}",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // 🔹 Live Rating
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(widget.type)
                  .doc(widget.docId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final data =
                    snapshot.data!.data() as Map<String, dynamic>? ?? {};
                final rating = (data["rating"] ?? 0).toDouble();
                final count = (data["ratingCount"] ?? 0).toInt();

                return Chip(
                  label: Text(
                    "${rating.toStringAsFixed(1)} ($count ratings)",
                    style: const TextStyle(fontSize: 14),
                  ),
                  avatar: const Icon(Icons.star,
                      color: Colors.orange, size: 18),
                  backgroundColor: Colors.yellow.shade50,
                );
              },
            ),
            const SizedBox(height: 16),

            // Location button
            if (hasLocation)
              ElevatedButton.icon(
                onPressed: () => _openMap(lat, lng),
                icon: const Icon(Icons.map, color: Colors.white),
                label: const Text("View Location",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            const SizedBox(height: 20),

            // Review section
            const Text("Submit your review",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(Icons.star,
                      size: 30,
                      color: index < userRating
                          ? Colors.orange
                          : Colors.grey[400]),
                  onPressed: () => setState(() => userRating = index + 1.0),
                );
              }),
            ),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Write your review...",
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                ),
                child: const Text("Submit Review",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),

            // Reviews list
            const Text("Reviews",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(widget.type)
                  .doc(widget.docId)
                  .collection("reviews")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Text("No reviews yet.");

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final d = docs[i].data() as Map<String, dynamic>;
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: const Icon(Icons.person, color: Colors.black),
                        ),
                        title: Text(d["user"] ?? "",
                            style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(d["review"] ?? ""),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.orange, size: 18),
                            const SizedBox(width: 4),
                            Text("${d["rating"] ?? 0}"),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
