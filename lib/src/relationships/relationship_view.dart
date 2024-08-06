import 'package:flutter/material.dart';
import 'package:animated_emoji/animated_emoji.dart';

import 'relationship_model.dart';

class RelationshipView extends StatefulWidget {
  final Relationship relationship;

  const RelationshipView({Key? key, required this.relationship})
      : super(key: key);

  @override
  _RelationshipViewState createState() => _RelationshipViewState();
}

class _RelationshipViewState extends State<RelationshipView> {
  bool _isExpanded = false;

  // Helper method to get AnimatedEmoji based on emoji string
  AnimatedEmoji _getAnimatedEmoji(String? emoji) {
    switch (emoji) {
      case 'smile':
        return AnimatedEmoji(AnimatedEmojis.smileWithBigEyes);
      case 'proud':
        return AnimatedEmoji(AnimatedEmojis.holdingBackTears);
      case 'sad':
        return AnimatedEmoji(AnimatedEmojis.sad);
      case 'angry':
        return AnimatedEmoji(AnimatedEmojis.angry);
      case 'funny':
        return AnimatedEmoji(AnimatedEmojis.laughing);
      case 'fearful':
        return AnimatedEmoji(AnimatedEmojis.screaming);
      case 'bothered':
        return AnimatedEmoji(AnimatedEmojis.laughing);
      case 'romantic':
        return AnimatedEmoji(AnimatedEmojis.heartEyes);
      case 'neglected':
        return AnimatedEmoji(AnimatedEmojis.expressionless);
      case 'worried':
        return AnimatedEmoji(AnimatedEmojis.worried);
      case 'liar':
        return AnimatedEmoji(AnimatedEmojis.liar);
      case 'muscle':
        return AnimatedEmoji(AnimatedEmojis.muscle);
      default:
        return AnimatedEmoji(AnimatedEmojis.neutralFace);
    }
  }

  @override
  Widget build(BuildContext context) {
    String emoji = widget.relationship.current_standing?['emoji'] ?? 'neutral';
    String summary = widget.relationship.current_standing?['summary'] ??
        'No current standing information';

    return Scaffold(
        appBar: AppBar(
          title: Text('Relationship with'),
        ),
        body: Card(
          margin: EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Top fold with background image, name, and animated emoji
              Container(
                height: 200,
                decoration: const BoxDecoration(
                    // image: DecorationImage(
                    //   image: AssetImage('assets/images/relationship_background.jpg'),
                    //   fit: BoxFit.cover,
                    // ),
                    ),
                child: Stack(
                  children: [
                    // Gradient overlay for better text visibility
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xff3371FF),
                            Color(0xff8426D6),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.relationship.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: _getAnimatedEmoji(emoji),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Current standing summary
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  summary,
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),

              // Expand/collapse button
              ListTile(
                title: Text(
                  'Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon:
                      Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ),

              // Expandable content
              if (_isExpanded) ...[
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Type: ${widget.relationship.type ?? 'Not specified'}'),
                      SizedBox(height: 8),
                      Text('Tags: ${widget.relationship.tags.join(', ')}'),
                      SizedBox(height: 8),
                      Text(
                          'Profiles: ${widget.relationship.profiles.join(', ')}'),
                      SizedBox(height: 8),
                      Text('Notes: ${widget.relationship.notes ?? 'No notes'}'),
                      SizedBox(height: 8),
                      Text(
                          'Created: ${widget.relationship.createdAt.toString()}'),
                      Text(
                          'Updated: ${widget.relationship.updatedAt.toString()}'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ));
  }
}
