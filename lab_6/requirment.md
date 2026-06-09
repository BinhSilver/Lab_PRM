# Technical Specification: Responsive Movie Genre Browsing Screen (Lab 6)

## 1. Tổng quan & Yêu cầu kỹ thuật cốt lõi
* [cite_start]**Công nghệ:** Chỉ sử dụng Flutter và Dart thuần, tuyệt đối không dùng thư viện bên thứ ba (third-party packages)[cite: 40].
* [cite_start]**Kiến trúc:** Toàn bộ ứng dụng phải được code gọn trong một file duy nhất (`main.dart`) để có thể chạy trực tiếp trên DartPad[cite: 41].
* [cite_start]**Mục tiêu:** Xây dựng màn hình tìm kiếm và lọc phim responsive, tương thích với cả điện thoại nhỏ, màn hình lớn, tablet và web[cite: 3].
* [cite_start]**Thành phần cốt lõi:** Yêu cầu sử dụng `MediaQuery`, `LayoutBuilder`, `Wrap`, `Expanded`, và `ListView`/`GridView` để xây dựng layout thích ứng[cite: 4, 5, 6, 7].

## 2. Cấu trúc Dữ liệu (Data Model)
* [cite_start]**Class `Movie`:** Khởi tạo một class chứa các thông tin cơ bản của một bộ phim[cite: 61].
* [cite_start]**Các trường dữ liệu (Fields):** Cần khai báo các biến `title` (String), `year` (int), `genres` (List<String>), `posterUrl` (String), và `rating` (double)[cite: 62, 63, 64, 65, 66].
* [cite_start]**Dữ liệu giả (Mock Data):** Cần tạo một biến danh sách hằng số (`const list`) gồm 3 đến 6 bộ phim mẫu để test UI mà không cần gọi API thực[cite: 67, 68].

## 3. Kiến trúc Giao diện (UI Components)
* [cite_start]**Base Layout:** Toàn bộ nội dung màn hình phải được bọc trong `SafeArea` để tránh bị lẹm vào phần notch hay camera cutout của điện thoại[cite: 43, 72].
* [cite_start]**Header:** Hiển thị một tiêu đề rõ ràng ở đầu trang, ví dụ: "Find a Movie"[cite: 21, 74].
* [cite_start]**Search Bar:** Xây dựng một `TextField` được bọc trong container bo góc để người dùng nhập từ khóa tìm kiếm phim[cite: 22, 77].
* [cite_start]**Genre Chips:** Dùng widget `Wrap` chứa các chip thể loại phim (Action, Drama, Comedy...), giúp các chip tự động rớt dòng khi tràn màn hình ngang[cite: 23, 44, 84, 88].
* [cite_start]**Sort Dropdown:** Thiết kế một nút xổ xuống (`DropdownButton`) chứa ít nhất 4 tùy chọn sắp xếp: A–Z, Z–A, Year, Rating[cite: 24, 25, 26, 27, 28, 91].
* [cite_start]**Movie Card:** Mỗi thẻ hiển thị phim phải có hình ảnh poster (dùng ảnh placeholder từ internet), tiêu đề phim và năm sản xuất[cite: 29, 30, 31, 32, 105, 106, 107, 108].

## 4. Logic Xử lý (Business Logic)
* [cite_start]**State Management:** Khởi tạo các biến trạng thái bao gồm `searchQuery` (chuỗi rỗng), `selectedGenres` (Set hoặc List), và `selectedSort` (mặc định "A-Z")[cite: 78, 83, 91].
* [cite_start]**Xử lý Tìm kiếm:** Cập nhật biến `searchQuery` qua hàm `setState` ngay khi `TextField` kích hoạt sự kiện `onChanged`[cite: 79].
* [cite_start]**Xử lý Lọc Thể loại:** Khi người dùng tap vào một chip, nếu chip đó đã được chọn thì gỡ khỏi `selectedGenres`, nếu chưa thì thêm mới vào[cite: 85, 86, 87].
* [cite_start]**Pipeline Lọc & Sắp xếp:** Tạo một danh sách hiển thị động (`visibleMovies`) bên trong hàm `build()`[cite: 95].
* [cite_start]**Điều kiện Lọc:** Tiến hành lọc theo từ khóa (dùng `.toLowerCase()` để không phân biệt hoa thường) và lọc theo thể loại (chỉ giữ lại phim có chứa ít nhất một thể loại đang được chọn)[cite: 34, 35, 96, 97, 99].
* [cite_start]**Điều kiện Sắp xếp:** Gọi hàm `.sort()` trên danh sách phim đã lọc để sắp xếp theo giá trị hiện tại của `selectedSort` trước khi đưa ra UI[cite: 98, 99].

## 5. Xử lý Responsive (Layout Adaptation)
* [cite_start]**Vùng cuộn:** Bọc khu vực hiển thị danh sách phim bằng widget `Expanded` nằm trong `Column` chính để chiếm toàn bộ không gian trống phía dưới[cite: 101].
* [cite_start]**Kích hoạt Breakpoint:** Sử dụng `LayoutBuilder` đọc thuộc tính `constraints.maxWidth` để phân nhánh logic render giao diện[cite: 102].
* [cite_start]**Mobile Layout (Dưới 800px):** Trả về `ListView.builder` để hiển thị danh sách thẻ phim theo một cột dọc duy nhất[cite: 37, 103, 129].
* [cite_start]**Tablet/Web Layout (Từ 800px trở lên):** Trả về `GridView.count` với thông số `crossAxisCount: 2` để dàn danh sách phim thành hai cột song song[cite: 38, 104, 130].

## 6. Tính năng Nâng cao (Bonus Enhancements)
* [cite_start]**Bộ đếm Thể loại:** Tích hợp một badge nhỏ hiển thị tổng số lượng thể loại phim đang được active[cite: 51].
* [cite_start]**Điểm Đánh giá:** Hiển thị điểm số rating của phim dưới dạng dãy ngôi sao hoặc giá trị số[cite: 52].
* [cite_start]**Nút Reset:** Bổ sung một nút "Clear filters" tiện dụng để người dùng xóa nhanh tất cả các bộ lọc hiện tại[cite: 53].
* [cite_start]**Responsive Poster:** Ứng dụng thêm `LayoutBuilder` bên trong nội bộ từng thẻ phim để tinh chỉnh tỷ lệ ảnh poster sao cho đẹp nhất trên cả phone và tablet[cite: 54, 109].