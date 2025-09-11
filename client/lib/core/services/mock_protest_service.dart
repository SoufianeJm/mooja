import '../models/protest_model.dart';

class MockProtestService {
  static List<Protest> getMockProtests() {
    final now = DateTime.now();
    
    return [
      // Today - 2 protests
      Protest(
        id: '1',
        title: 'March For Gaza',
        dateTime: DateTime(now.year, now.month, now.day, 23, 0),
        country: 'Morocco',
        city: 'Casablanca',
        location: 'United Nations Square, Casablanca',
        organizerId: 'org1',
        organizer: const Organization(
          id: 'org1',
          username: 'students_union',
          name: "Student's Union",
pictureUrl: 'assets/images/avatar1.png',
        ),
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Protest(
        id: '2',
        title: 'Climate Action Now',
        dateTime: DateTime(now.year, now.month, now.day, 18, 30),
        country: 'Morocco',
        city: 'Rabat',
        location: 'Parliament Building, Rabat',
        organizerId: 'org2',
        organizer: const Organization(
          id: 'org2',
username: 'green_morocco',
          name: 'Green Morocco Initiative',
          pictureUrl: 'assets/images/avatar2.png',
        ),
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      
      // Tomorrow - 3 protests
      Protest(
        id: '3',
        title: 'United For Palestine',
        dateTime: DateTime(now.year, now.month, now.day + 1, 11, 0),
        country: 'Morocco',
        city: 'Casablanca',
        location: 'Bab Al Had Square',
        organizerId: 'org3',
        organizer: const Organization(
          id: 'org3',
username: 'workers_union',
          name: "Worker's Union For Palestine",
          pictureUrl: 'assets/images/avatar3.png',
        ),
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      Protest(
        id: '4',
        title: 'Education Reform Rally',
        dateTime: DateTime(now.year, now.month, now.day + 1, 14, 0),
        country: 'Morocco',
        city: 'Fes',
        location: 'University Campus, Fes',
        organizerId: 'org4',
        organizer: const Organization(
          id: 'org4',
username: 'teachers_association',
          name: 'Teachers Association',
          pictureUrl: 'assets/images/avatar4.png',
        ),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Protest(
        id: '5',
        title: 'Healthcare Workers March',
        dateTime: DateTime(now.year, now.month, now.day + 1, 16, 30),
        country: 'Morocco',
        city: 'Casablanca',
        location: 'Ibn Rochd Hospital',
        organizerId: 'org5',
        organizer: const Organization(
          id: 'org5',
username: 'healthcare_union',
          name: 'Healthcare Workers Union',
          pictureUrl: 'assets/images/avatar5.png',
        ),
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      
      // Day after tomorrow - 1 protest
      Protest(
        id: '6',
        title: 'Women\'s Rights Assembly',
        dateTime: DateTime(now.year, now.month, now.day + 2, 10, 0),
        country: 'Morocco',
        city: 'Marrakech',
        location: 'Jemaa el-Fnaa Square',
        organizerId: 'org6',
        organizer: const Organization(
          id: 'org6',
username: 'womens_rights_morocco',
          name: 'Women\'s Rights Morocco',
          pictureUrl: 'assets/images/avatar6.png',
        ),
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now.subtract(const Duration(days: 6)),
      ),
      
      // 4 days from now - 1 protest
      Protest(
        id: '7',
        title: 'Anti-Corruption March',
        dateTime: DateTime(now.year, now.month, now.day + 4, 15, 0),
        country: 'Morocco',
        city: 'Tangier',
        location: 'Grand Socco Square',
        organizerId: 'org7',
        organizer: const Organization(
          id: 'org7',
username: 'transparency_morocco',
          name: 'Transparency Morocco',
          pictureUrl: 'assets/images/avatar7.png',
        ),
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
    ];
  }
  
  /// Groups protests by date and returns them sorted chronologically
  static Map<DateTime, List<Protest>> getGroupedProtests() {
    final protests = getMockProtests();
    final Map<DateTime, List<Protest>> grouped = {};
    
    for (final protest in protests) {
      // Create a date key (without time)
      final dateKey = DateTime(
        protest.dateTime.year,
        protest.dateTime.month,
        protest.dateTime.day,
      );
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(protest);
    }
    
    // Sort each day's protests by time
    grouped.forEach((date, protests) {
      protests.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    });
    
    // Return as sorted map (by date)
    final sortedKeys = grouped.keys.toList()..sort();
    final sortedMap = <DateTime, List<Protest>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }
    
    return sortedMap;
  }
}
