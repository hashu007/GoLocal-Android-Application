import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login/ProfilePage.dart';
import 'package:login/PublicDashboard.dart';
import 'package:login/SignIn.dart';

const _cities = <String>[
  "Karachi",
  "Lahore",
  "Islamabad",
  "Faisalabad",
  "Rawalpindi",
];

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Admin Dashboard",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Attractions"),
              Tab(text: "Events"),
              Tab(text: "Reviews"),
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
                      child: Text(
                        "No user logged in",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                );
              }

              return StreamBuilder<firestore.DocumentSnapshot>(
                stream: firestore.FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const DrawerHeader(
                      decoration: BoxDecoration(color: Colors.blue),
                      child: Text(
                        "No profile data found",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final name = data["name"] ?? "User";
                  final email = data["email"] ?? "No Email";
                  final profileImageUrl = data["imageUrl"] ?? "";

                  return Column(
                    children: [
                      UserAccountsDrawerHeader(
                        decoration: const BoxDecoration(color: Colors.blue),
                        accountName: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        accountEmail: Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        currentAccountPicture: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : null,
                          child: profileImageUrl.isEmpty
                              ? const Icon(Icons.person,
                              size: 40, color: Colors.blue)
                              : null,
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.dashboard,
                                  color: Colors.blue),
                              title: const Text("Public Dashboard",
                                  style: TextStyle(color: Colors.black)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PublicDashboard()),
                                );
                              },
                            ),
                            ListTile(
                              leading:
                              const Icon(Icons.person, color: Colors.blue),
                              title: const Text("Profile",
                                  style: TextStyle(color: Colors.black)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePage()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Signin()),
                            );
                          },
                          icon:
                          const Icon(Icons.logout, color: Colors.white),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              "Logout",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 2,
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
          color: Colors.lightBlue.shade50,
          child: const TabBarView(
            children: [
              AttractionsTab(),
              EventsTab(),
              ReviewsTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- ATTRACTIONS --------------------
class AttractionsTab extends StatelessWidget {
  const AttractionsTab({super.key});

  void _openAddOrEditDialog(BuildContext context,
      {String? docId, Map<String, dynamic>? data}) {
    final nameCtrl = TextEditingController(text: data?['name'] ?? '');
    final descCtrl = TextEditingController(text: data?['description'] ?? '');
    final latController =
    TextEditingController(text: (data?['lat']?.toString() ?? ''));
    final lngController =
    TextEditingController(text: (data?['lng']?.toString() ?? ''));
    String city = data?['city'] ?? _cities.first;
    String? imageUrl = data?['imageUrl'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickAndUploadImage() async {
              final picker = ImagePicker();
              final pickedFile =
              await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile == null) return;
              final fileBytes = await pickedFile.readAsBytes();
              final storageRef = FirebaseStorage.instance
                  .ref()
                  .child('attractions_images')
                  .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

              try {
                final uploadTask = await storageRef.putData(fileBytes);
                final url = await uploadTask.ref.getDownloadURL();
                setState(() {
                  imageUrl = url;
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Image upload failed: $e')),
                );
              }
            }

            return AlertDialog(
              title: Text(docId == null ? "Add Attraction" : "Edit Attraction"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (imageUrl != null && imageUrl!.isNotEmpty)
                      Image.network(imageUrl!,
                          height: 160, fit: BoxFit.cover)
                    else
                      Container(
                        height: 160,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.photo, size: 48),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: pickAndUploadImage,
                      icon: const Icon(Icons.upload),
                      label: const Text("Upload Image"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: "Name")),
                    const SizedBox(height: 8),
                    TextField(
                        controller: descCtrl,
                        decoration:
                        const InputDecoration(labelText: "Description")),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: city,
                      items: _cities
                          .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => city = v!,
                      decoration: const InputDecoration(labelText: "City"),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: latController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration:
                      const InputDecoration(labelText: "Latitude"),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: lngController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration:
                      const InputDecoration(labelText: "Longitude"),
                    ),
                    const SizedBox(height: 8),
                    _ReadOnlyRatingNote(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final lat =
                        double.tryParse(latController.text.trim()) ?? 0.0;
                    final lng =
                        double.tryParse(lngController.text.trim()) ?? 0.0;
                    final payload = <String, dynamic>{
                      "name": name,
                      "description": descCtrl.text.trim(),
                      "city": city,
                      "rating":
                      (data?['rating'] as num?)?.toDouble() ?? 0.0,
                      "imageUrl": imageUrl,
                      "lat": lat,
                      "lng": lng,
                    };
                    final col = firestore.FirebaseFirestore.instance
                        .collection("attractions");
                    try {
                      if (docId == null) {
                        await col.add(payload);
                      } else {
                        await col.doc(docId).update(payload);
                      }
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Failed to save: $e")));
                      }
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Attraction"),
        content:
        const Text("Are you sure you want to delete this attraction?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete")),
        ],
      ),
    );
    if (ok == true) {
      await firestore.FirebaseFirestore.instance
          .collection("attractions")
          .doc(id)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<firestore.QuerySnapshot<Map<String, dynamic>>>(
          stream: firestore.FirebaseFirestore.instance
              .collection("attractions")
              .orderBy("name")
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return const Center(
                  child: Text("Error loading attractions"));
            }
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Center(child: Text("No attractions found"));
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final d = docs[i];
                final data = d.data();
                final rating =
                    (data['rating'] as num?)?.toDouble() ?? 0.0;
                final imageUrl = data['imageUrl'] as String?;
                return Card(
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardImage(imageUrl: imageUrl),
                      ListTile(
                        title: Text(data['name'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                              "${data['description'] ?? ''}\nCity: ${data['city'] ?? ''}\nLat: ${data['lat'] ?? ''}, Lng: ${data['lng'] ?? ''}"),
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(
                                "${rating.toStringAsFixed(1)} (${(data['ratingCount'] ?? 0)})",
                                style: const TextStyle(fontSize: 12),
                              ),
                              avatar: const Icon(Icons.star,
                                  size: 16, color: Colors.orange),
                              backgroundColor: Colors.yellow.shade50,
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _openAddOrEditDialog(context,
                                  docId: d.id, data: data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, d.id),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _openAddOrEditDialog(context),
            icon: const Icon(Icons.add),
            label: const Text("Add"),
          ),
        ),
      ],
    );
  }
}

// -------------------- EVENTS --------------------
class EventsTab extends StatelessWidget {
  const EventsTab({super.key});

  void _openAddOrEditDialog(BuildContext context,
      {String? docId, Map<String, dynamic>? data}) {
    final titleCtrl = TextEditingController(text: data?['title'] ?? '');
    final dateCtrl = TextEditingController(text: data?['date'] ?? '');
    final latController =
    TextEditingController(text: (data?['lat']?.toString() ?? ''));
    final lngController =
    TextEditingController(text: (data?['lng']?.toString() ?? ''));
    String city = data?['city'] ?? _cities.first;
    String? imageUrl = data?['imageUrl'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickAndUploadImage() async {
              final picker = ImagePicker();
              final pickedFile =
              await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile == null) return;
              final fileBytes = await pickedFile.readAsBytes();
              final storageRef = FirebaseStorage.instance
                  .ref()
                  .child('events_images')
                  .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
              try {
                final uploadTask = await storageRef.putData(fileBytes);
                final url = await uploadTask.ref.getDownloadURL();
                setState(() {
                  imageUrl = url;
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Image upload failed: $e')),
                );
              }
            }

            return AlertDialog(
              title: Text(docId == null ? "Add Event" : "Edit Event"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (imageUrl != null && imageUrl!.isNotEmpty)
                      Image.network(imageUrl!,
                          height: 160, fit: BoxFit.cover)
                    else
                      Container(
                        height: 160,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.photo, size: 48),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: pickAndUploadImage,
                      icon: const Icon(Icons.upload),
                      label: const Text("Upload Image"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(labelText: "Title")),
                    const SizedBox(height: 8),
                    TextField(
                        controller: dateCtrl,
                        decoration: const InputDecoration(labelText: "Date")),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: city,
                      items: _cities
                          .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => city = v!,
                      decoration: const InputDecoration(labelText: "City"),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: latController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration:
                      const InputDecoration(labelText: "Latitude"),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: lngController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration:
                      const InputDecoration(labelText: "Longitude"),
                    ),
                    const SizedBox(height: 8),
                    _ReadOnlyRatingNote(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    if (title.isEmpty) return;
                    final lat =
                        double.tryParse(latController.text.trim()) ?? 0.0;
                    final lng =
                        double.tryParse(lngController.text.trim()) ?? 0.0;
                    final payload = <String, dynamic>{
                      "title": title,
                      "date": dateCtrl.text.trim(),
                      "city": city,
                      "rating":
                      (data?['rating'] as num?)?.toDouble() ?? 0.0,
                      "imageUrl": imageUrl,
                      "lat": lat,
                      "lng": lng,
                    };
                    final col = firestore.FirebaseFirestore.instance
                        .collection("events");
                    try {
                      if (docId == null) {
                        await col.add(payload);
                      } else {
                        await col.doc(docId).update(payload);
                      }
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Failed to save: $e")));
                      }
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Event"),
        content: const Text("Are you sure you want to delete this event?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete")),
        ],
      ),
    );
    if (ok == true) {
      await firestore.FirebaseFirestore.instance
          .collection("events")
          .doc(id)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<firestore.QuerySnapshot<Map<String, dynamic>>>(
          stream: firestore.FirebaseFirestore.instance
              .collection("events")
              .orderBy("title")
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return const Center(child: Text("Error loading events"));
            }
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Center(child: Text("No events found"));
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final d = docs[i];
                final data = d.data();
                final rating =
                    (data['rating'] as num?)?.toDouble() ?? 0.0;
                final imageUrl = data['imageUrl'] as String?;
                return Card(
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardImage(imageUrl: imageUrl),
                      ListTile(
                        title: Text(data['title'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                              "Date: ${data['date'] ?? ''}\nCity: ${data['city'] ?? ''}\nLat: ${data['lat'] ?? ''}, Lng: ${data['lng'] ?? ''}"),
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(
                                "${rating.toStringAsFixed(1)} (${(data['ratingCount'] ?? 0)})",
                                style: const TextStyle(fontSize: 12),
                              ),
                              avatar: const Icon(Icons.star,
                                  size: 16, color: Colors.orange),
                              backgroundColor: Colors.yellow.shade50,
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _openAddOrEditDialog(context,
                                  docId: d.id, data: data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, d.id),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _openAddOrEditDialog(context),
            icon: const Icon(Icons.add),
            label: const Text("Add"),
          ),
        ),
      ],
    );
  }
}

// -------------------- REVIEWS --------------------


class ReviewsTab extends StatelessWidget {
  const ReviewsTab({super.key});

  Future<String> _getParentTitle(firestore.DocumentReference parentRef) async {
    final snap = await parentRef.get();
    final data = snap.data() as Map<String, dynamic>?;

    return data?['name'] ?? data?['title'] ?? 'Untitled';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firestore.QuerySnapshot>(
      stream: firestore.FirebaseFirestore.instance
          .collectionGroup("reviews")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return const Center(child: Text("Error loading reviews"));

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Text("No reviews yet"));

        docs.sort((a, b) {
          final t1 = (a.data() as Map<String, dynamic>)['timestamp'] as firestore.Timestamp?;
          final t2 = (b.data() as Map<String, dynamic>)['timestamp'] as firestore.Timestamp?;
          return (t2?.toDate() ?? DateTime(1970))
              .compareTo(t1?.toDate() ?? DateTime(1970));
        });

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final d = docs[index];
            final data = d.data() as Map<String, dynamic>;

            final name = data['name'] ?? data['user'] ?? data['userEmail'] ?? 'Anonymous';
            final reviewText = data['review'] ?? '';
            final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
            final timestamp = (data['timestamp'] as firestore.Timestamp?)?.toDate();

            final parentRef = d.reference.parent.parent;

            return FutureBuilder<String>(
              future: parentRef != null ? _getParentTitle(parentRef) : Future.value("Untitled"),
              builder: (context, titleSnap) {
                final title = titleSnap.data ?? "Loading...";

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text("By: $name",
                            style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Row(
                          children: List.generate(
                            5,
                                (i) => Icon(
                              Icons.star,
                              size: 16,
                              color: i < rating.round()
                                  ? Colors.orange
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(reviewText),
                        if (timestamp != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            "${timestamp.toLocal()}".split(' ')[0],
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ]
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: "Delete Review",
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete Review"),
                            content: const Text(
                                "Are you sure you want to delete this review?"),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel")),
                              ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text("Delete")),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await d.reference.delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Review deleted")),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// -------------------- SHARED WIDGETS --------------------
class _CardImage extends StatelessWidget {
  final String? imageUrl;
  const _CardImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return imageUrl != null && imageUrl!.isNotEmpty
        ? Image.network(imageUrl!,
        width: double.infinity,
        height: 160,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 160,
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image),
        ))
        : Container(
      height: 160,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.photo, size: 48),
    );
  }
}

class _ReadOnlyRatingNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      "Note: Rating is auto-calculated from user reviews.",
      style: TextStyle(fontSize: 12, color: Colors.grey),
    );
  }
}
