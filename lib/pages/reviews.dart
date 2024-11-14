import 'package:chat/providers/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReviewPage extends ConsumerStatefulWidget {
  const ReviewPage({super.key});

  @override
  ConsumerState<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends ConsumerState<ReviewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _reviewController = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // FocusNode for the TextField

  // Method to add a new review to Firestore
  void _addReview() async {
    if (_reviewController.text.isNotEmpty) {
      try {
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('reviews').add({
            'userId': user.uid,
            'email': user.email,
            'review': _reviewController.text,
            'timestamp': FieldValue.serverTimestamp(),
          });
          _reviewController.clear();
          _focusNode.unfocus(); // Unfocus the TextField after review is added
        }
      } catch (e) {
        print('Error adding review: $e');
      }
    }
  }

  // Method to delete a review
  void _deleteReview(String reviewId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Check if the review belongs to the current user before deleting
        DocumentSnapshot reviewDoc =
            await _firestore.collection('reviews').doc(reviewId).get();
        if (reviewDoc.exists && reviewDoc['userId'] == user.uid) {
          await _firestore.collection('reviews').doc(reviewId).delete();
          _focusNode.unfocus(); // Unfocus the TextField after review is deleted
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You cannot delete this review.')),
          );
        }
      }
    } catch (e) {
      print('Error deleting review: $e');
    }
  }

  // Stream to fetch reviews from Firestore
  Stream<List<Map<String, dynamic>>> _getReviews() {
    return _firestore
        .collection('reviews')
        .orderBy('timestamp', descending: true) // Show the latest reviews first
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()}; // Add doc id to the review
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
        backgroundColor:
            isDarkMode ? Colors.deepPurple.shade700 : Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add your review:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reviewController,
              focusNode: _focusNode, // Assign FocusNode to the TextField
              decoration: InputDecoration(
                hintText: 'Enter your review here...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(16),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              ),
              maxLines: 4,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Button to submit the review
            Center(
              child: ElevatedButton(
                onPressed: _addReview,
                style: ElevatedButton.styleFrom(
                  foregroundColor: isDarkMode ? Colors.black : Colors.white,
                  backgroundColor: isDarkMode
                      ? Colors.deepPurple.shade700
                      : Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Submit Review',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Previous Reviews:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),

            // ListView for the reviews list
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getReviews(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading reviews'));
                  }

                  if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No reviews yet.'));
                  }

                  final reviews = snapshot.data!;

                  return ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      final String reviewUserId =
                          review['userId']; // The userId of the review
                      final bool isCurrentUserReview =
                          reviewUserId == _auth.currentUser?.uid;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: isCurrentUserReview
                            ? GestureDetector(
                                onLongPress: () {
                                  // Show options to delete when long pressed
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Wrap(
                                        children: [
                                          // Show delete option only for the current user's reviews
                                          ListTile(
                                            leading: const Icon(Icons.delete),
                                            title: const Text('Delete Review'),
                                            onTap: () {
                                              _deleteReview(review['id']);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.cancel),
                                            title: const Text('Cancel'),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Card(
                                  color: isDarkMode
                                      ? Colors.grey[850]
                                      : Colors.white,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            review['review'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Card(
                                color: isDarkMode
                                    ? Colors.grey[850]
                                    : Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          review['review'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
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
