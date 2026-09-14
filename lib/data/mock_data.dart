import '../models/novel.dart';
import '../models/chapter.dart';
import '../models/comment.dart';
import '../models/user.dart';

class MockData {
  static final User demoUser = User(
    id: 'demo-user-1',
    email: 'reader@relsreading.com',
    username: 'นักอ่านแดนสวรรค์',
    role: 'user',
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );

  static final List<Novel> sampleNovels = [
    Novel(
      id: 'mock-novel-1',
      title: 'หวนคืนสู่บัลลังก์จอมราชันย์ (Return of the Sovereign King)',
      description:
          'หลังจากการทรยศหักหลังในสงครามหมื่นภพ จอมราชันย์ "หลินเฟิง" ได้ตื่นขึ้นมาอีกครั้งในร่างของเด็กหนุ่มตระกูลตกอับ พร้อมกับความทรงจำและวิชากลืนสวรรค์ที่สะเทือนทั้งปฐพี!',
      coverUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600&auto=format&fit=crop&q=80',
      authorId: 'author-1',
      author: AuthorInfo(id: 'author-1', username: 'พยัคฆ์ทมิฬคำราม'),
      chaptersCount: 128,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Novel(
      id: 'mock-novel-2',
      title: 'ลิขิตรักข้ามกาลเวลา พันธนาการดวงใจ',
      description:
          'แพทย์สาวอัจฉริยะยุคศตวรรษที่ 21 ประสบอุบัติเหตุตื่นขึ้นมาในยุคโบราณ กลายเป็นพระชายาผู้ถูกทอดทิ้งของท่านอ๋องผู้เย็นชา นางจึงต้องใช้ความรู้ทางการแพทย์และไหวพริบเอาชีวิตรอด!',
      coverUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&auto=format&fit=crop&q=80',
      authorId: 'author-2',
      author: AuthorInfo(id: 'author-2', username: 'บุปผาโปรยปราย'),
      chaptersCount: 95,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Novel(
      id: 'mock-novel-3',
      title: 'ไซเบอร์พังค์ 2099: กำเนิดสตรีทเลเจนด์',
      description:
          'ในมหานครนีออนที่ผู้คนหลงระเริงกับเทคโนโลยีและชิปไซเบอร์เนติกส์ แฮกเกอร์หนุ่มไร้สังกัดได้ค้นพบโปรเจกต์ลับของเมกะคอร์ปอเรชัน ที่หมายจะล้างสมองมวลมนุษยชาติทั้งเมือง',
      coverUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600&auto=format&fit=crop&q=80',
      authorId: 'author-3',
      author: AuthorInfo(id: 'author-3', username: 'NeonGhost'),
      chaptersCount: 64,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Novel(
      id: 'mock-novel-4',
      title: 'ร้านสะดวกซื้อแห่งมิติคู่ขนาน',
      description:
          'ร้านสะดวกซื้อเล็กๆ ที่เปิดเฉพาะตอนเที่ยงคืน มีสินค้าแปลกประหลาดที่ช่วยเยียวยาบาดแผลในหัวใจของผู้มาเยือน จากเรื่องราวสุดอบอุ่นหัวใจและปาฏิหาริย์ที่คาดไม่ถึง',
      coverUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=600&auto=format&fit=crop&q=80',
      authorId: 'author-4',
      author: AuthorInfo(id: 'author-4', username: 'ชาอุ่นในสายฝน'),
      chaptersCount: 42,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static final Map<String, List<Chapter>> sampleChapters = {
    'mock-novel-1': [
      Chapter(
        id: 'c1-1',
        novelId: 'mock-novel-1',
        chapterNumber: 1,
        title: 'บทที่ 1: การตื่นขึ้นมาอีกครั้ง',
        content: '''
สายฝนโปรยปรายลงมาอย่างไม่ขาดสาย หยาดน้ำกระทบกับหลังคาไม้ผุพังจนเกิดเสียงดังก้อง

หลินเฟิงค่อยๆ ลืมตาขึ้น สิ่งแรกที่เขารู้สึกคือความเจ็บปวดรวดร้าวที่แล่นไปทั่วร่างราวกับกระดูกทุกท่อนถูกบดละเอียด

"นี่ข้า... ยังไม่ตายงั้นหรือ?"

เขายกมืออันผอมแห้งและสั่นเทาขึ้นดู มือคู่นี้มิใช่มือของจอมราชันย์ผู้กุมชะตาใต้หล้า แต่เป็นมือของเด็กหนุ่มผู้หนึ่งที่อ่อนแอเหลือเกิน

ทันใดนั้น ความทรงจำจำนวนมหาศาลก็ไหลบ่าเข้ามาในห้วงความคิด ร่างนี้มีนามว่าหลินเฟิงเช่นเดียวกัน ทว่าเป็นนายน้อยแห่งตระกูลสาขาที่ถูกขับไล่มายังชายแดน เนื่องจากชีพจรลมปราณพิการไม่อาจฝึกยุทธ์ได้

"สวรรค์เล่นตลกกับข้ากระนั้นหรือ..." หลินเฟิงแค่นยิ้มเย็น แววตาที่เคยอ่อนแอพลันเปลี่ยนเป็นคมกริบดุจกระบี่เซียน

"ในเมื่อข้าได้รับโอกาสให้มีชีวิตอีกครั้ง ไม่ว่าชีพจรนี้จะพิการเพียงใด ด้วย 'คัมภีร์กลืนสวรรค์' ที่ข้าครอบครอง ไม่มีสิ่งใดในโลกนี้ที่จะหยุดยั้งข้าได้!"
        ''',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Chapter(
        id: 'c1-2',
        novelId: 'mock-novel-1',
        chapterNumber: 2,
        title: 'บทที่ 2: คัมภีร์กลืนสวรรค์',
        content: '''
หลินเฟิงนั่งขัดสมาธิบนเตียงไม้เก่าๆ ลมหายใจของเขาเริ่มเป็นจังหวะสม่ำเสมอ

แม้ร่างนี้จะขาดการบำรุงและไร้พลังปราณ แต่จุดเด่นที่สุดคือเส้นเอ็นที่ยังไม่ถูกเปิดออก นั่นหมายความว่าเขาสามารถเริ่มปูพื้นฐานใหม่ได้ตั้งแต่ศูนย์!

"กลืนสวรรค์ดูดปฐพี หลอมรวมจิตวิญญาณสู่หนึ่งเดียว!"

ถ้อยคำบทสวดโบราณดังก้องในจิตใจ ละอองปราณฟ้าดินรอบตัวเริ่มก่อตัวเป็นวังวนเล็กๆ และค่อยๆ ซึมซาบเข้าสู่จุดตันเถียนของเขา ความร้อนผ่าวแผ่ซ่านไปตามเส้นเลือด

ปัง!

เสียงทลายคอขวดดังขึ้นเบาๆ ในอก ภายในเวลาเพียงหนึ่งก้านธูป หลินเฟิงสามารถก้าวเข้าสู่ 'ขอบเขตหลอมกายาระดับหนึ่ง' ได้สำเร็จ หากคนในตระกูลมาเห็นเข้า คงต้องตกตะลึงจนตาค้างอย่างแน่นอน!
        ''',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      Chapter(
        id: 'c1-3',
        novelId: 'mock-novel-1',
        chapterNumber: 3,
        title: 'บทที่ 3: ผู้มาเยือนที่ไม่ได้รับเชิญ',
        content: '''
ตึง! ตึง!

เสียงเคาะประตูดังลั่นอย่างหยาบคาย จนฝุ่นบนเพดานร่วงหล่นลงมา

"ไอ้ขยะหลินเฟิง! จงเปิดประตูเดี๋ยวนี้! วันนี้ถึงกำหนดที่เจ้าต้องส่งมอบโอสถประจำเดือนให้คุณชายใหญ่แล้ว!"

เสียงตวาดแหลมสูงดังมาจากนอกบ้าน มันคือเสียงของ 'จ้าวเฉียง' ผู้คุ้มกันประจำตระกูลที่มักจะมารีดไถหลินเฟิงเป็นประจำ

หลินเฟิงลืมตาขึ้น ดวงตาฉายแววเย็นชาไร้ความหวาดกลัวดั่งเช่นในอดีต เขาลุกขึ้นยืน ปัดฝุ่นบนเสื้อผ้าช้าๆ

"เจ้ากำลังเร่งรัดความตายของตนเองอยู่ รู้ตัวหรือไม่..."
        ''',
        createdAt: DateTime.now().subtract(const Duration(days: 13)),
      ),
    ],
    'mock-novel-2': [
      Chapter(
        id: 'c2-1',
        novelId: 'mock-novel-2',
        chapterNumber: 1,
        title: 'บทที่ 1: ตื่นในร่างพระชายาผู้ถูกทอดทิ้ง',
        content: '''
กลิ่นกำยานหอมอ่อนๆ ผสมกับกลิ่นยาต้มลอยแตะจมูก

ลลิตา ศัลยแพทย์สาวมือหนึ่ง ค่อยๆ ลืมตาขึ้น แสงแดดยามเช้าลอดผ่านม่านผ้าไหมสีทองระยิบระยับ

"ที่นี่... ไม่ใช่ห้องผ่าตัด?" นางพึมพำกับตัวเอง

สาวใช้ตัวน้อยในชุดจีนโบราณที่นั่งเฝ้าข้างเตียงสะดุ้งตื่น ก่อนจะร้องไห้โฮออกมาด้วยความดีใจ

"พระชายา! พระชายาฟื้นแล้วหรือเพคะ! บ่าวคิดว่าจะไม่ได้พบพระองค์อีกแล้ว!"

ลลิตาแตะศีรษะที่ยังมีผ้าพันแผลเปื้อนเลือด ความทรงจำของร่างนี้หลั่งไหลเข้ามา... นางคือ 'มู่ชิงหลิน' พระชายาของฉินอ๋อง ผู้ถูกใส่ร้ายและกระโดดสระบัวเพื่อพิสูจน์ความบริสุทธิ์!
        ''',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ],
  };

  static final Map<String, List<Comment>> sampleComments = {
    'c1-1': [
      Comment(
        id: 'com-1',
        chapterId: 'c1-1',
        userId: 'user-a',
        content: 'เปิดเรื่องมาสนุกมากครับ! ชอบพระเอกสายโหด ไม่ยอมคนแบบนี้',
        user: CommentUser(id: 'user-a', username: 'แฟนพันธุ์แท้นิยายจีน'),
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Comment(
        id: 'com-2',
        chapterId: 'c1-1',
        userId: 'user-b',
        content: 'รออ่านบทต่อไปเลยครับ มาอัปบ่อยๆ นะคุณนักเขียน',
        user: CommentUser(id: 'user-b', username: 'มังกรทะยานฟ้า'),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ],
    'c1-2': [
      Comment(
        id: 'com-3',
        chapterId: 'c1-2',
        userId: 'user-c',
        content: 'วิชากลืนสวรรค์เท่มาก อยากรู้ว่าจะไปแก้แค้นยังไงต่อ',
        user: CommentUser(id: 'user-c', username: 'Bookworm99'),
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
  };
}
