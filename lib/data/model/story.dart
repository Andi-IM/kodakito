class Story {
  final String id;
  final String name;
  final String description;
  final String photoUrl;
  final DateTime createdAt;
  final double? lat;
  final double? lon;

  Story({
    required this.id,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.createdAt,
    this.lat,
    this.lon,
  });
}

final List<Story> dummyStories = [
  Story(
    id: '1',
    name: 'Dimas',
    description:
        'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s.',
    photoUrl: 'https://picsum.photos/id/237/400/200',
    createdAt: DateTime.now(),
  ),
  Story(
    id: '2',
    name: 'Arif',
    description:
        'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout.',
    photoUrl: 'https://picsum.photos/id/238/400/200',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Story(
    id: '3',
    name: 'Fikri',
    description:
        'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC.',
    photoUrl: 'https://picsum.photos/id/239/400/200',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Story(
    id: '4',
    name: 'Gilang',
    description:
        'There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour.',
    photoUrl: 'https://picsum.photos/id/240/400/200',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Story(
    id: '5',
    name: 'Budi',
    description:
        'The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum".',
    photoUrl: 'https://picsum.photos/id/241/400/200',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
  ),
  Story(
    id: '6',
    name: 'Siti',
    description:
        'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis.',
    photoUrl: 'https://picsum.photos/id/242/400/200',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Story(
    id: '7',
    name: 'Ahmad',
    description:
        'But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system.',
    photoUrl: 'https://picsum.photos/id/243/400/200',
    createdAt: DateTime.now().subtract(const Duration(days: 6)),
  ),
  Story(
    id: '8',
    name: 'Dewi',
    description:
        'At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident.',
    photoUrl: 'https://picsum.photos/id/244/400/200',
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  Story(
    id: '9',
    name: 'Rina',
    description:
        'On the other hand, we denounce with righteous indignation and dislike men who are so beguiled and demoralized by the charms of pleasure of the moment.',
    photoUrl: 'https://picsum.photos/id/245/400/200',
    createdAt: DateTime.now().subtract(const Duration(days: 8)),
  ),
  Story(
    id: '10',
    name: 'Joko',
    description:
        'Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est.',
    photoUrl: 'https://picsum.photos/id/246/400/200',
    createdAt: DateTime.now().subtract(const Duration(days: 9)),
  ),
];