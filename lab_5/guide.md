

**1. Objective**

* Trong bài lab này, sinh viên sẽ thiết kế và triển khai một ứng dụng "Movie Detail App" đơn giản.


* Ứng dụng nhằm minh họa cách sử dụng cơ chế điều hướng của Flutter (Navigator.push, MaterialPageRoute, hoặc named routes) và cấu tạo UI cơ bản.


* Dự án củng cố các ý tưởng chính từ Module 5 – Navigation & State Management.



**2. Requirements**

* Yêu cầu tạo một ứng dụng Flutter gồm hai màn hình chính.


* 
**Home Screen**: Hiển thị một danh sách cuộn các bộ phim bao gồm poster, title, và rating. *(Bạn sẽ cung cấp hình ảnh cho Antigravity tại đây)*.


* 
**Movie Detail Screen**: Hiển thị thông tin của bộ phim được chọn.


* Màn hình chi tiết cần có Poster ở dạng Hero banner với hiệu ứng gradient.


* Màn hình chi tiết cần hiển thị Title và genres dưới dạng các thẻ chips.


* Màn hình chi tiết cần có phần văn bản Overview.


* Màn hình chi tiết cần có các nút Action (Favorite / Rate / Share).


* Màn hình chi tiết cần có danh sách các trailer. *(Bạn sẽ cung cấp hình ảnh cho Antigravity tại đây)*.



**Technical Requirements**

* Việc điều hướng phải sử dụng Navigator.push + MaterialPageRoute.


* Hoặc có thể sử dụng Named routes (Navigator.pushNamed).


* Phải truyền đối tượng `Movie` giữa các màn hình.


* Layout phải có khả năng cuộn (scrollable) và phản hồi (responsive).


* Chỉ sử dụng dữ liệu mẫu tĩnh, không gọi API.


* Ứng dụng phải chạy chính xác trên DartPad và Android Studio / VS Code.



**Optional Enhancements**

* Triển khai nút chuyển đổi (toggle) Favorite để cập nhật state.


* Thêm một thanh tìm kiếm đơn giản để lọc phim.


* (Nâng cao) Thử nghiệm với deep-link để mở một trang chi tiết phim cụ thể.



**3. Guided Steps**

* 
**Step 1 – Project Setup**: Tạo dự án Flutter mới bằng lệnh `flutter create movie_app` hoặc mở DartPad Flutter.


* 
**Step 2 – Define Data Model**: Tạo lớp `Movie` với các trường id, title, posterUrl, overview, genres, rating, và danh sách Trailers.


* 
**Step 2 (Tiếp tục)**: Thêm file `sample_data.dart` chứa 2–3 đối tượng phim.


* 
**Step 3 – Build Home Screen**: Sử dụng `ListView.builder` để hiển thị từng thẻ phim.


* 
**Step 3 (Tiếp tục)**: Khi nhấn vào thẻ (On tap), điều hướng đến màn hình Movie Detail và truyền vào đối tượng được chọn.


* 
**Step 4 – Build Movie Detail Screen**: Bắt đầu cấu trúc UI với Blank Scaffold và AppBar.


* 
**Step 4 (Tiếp tục)**: Tạo Hero Banner bằng Stack, Image.network, và gradient.


* 
**Step 4 (Tiếp tục)**: Hiển thị Title và Genres sử dụng Column, Wrap, và Chip.


* 
**Step 4 (Tiếp tục)**: Thêm Overview text với Padding.


* 
**Step 4 (Tiếp tục)**: Tạo một Row chứa các IconButtons cho Favorite, Rate, và Share.


* 
**Step 4 (Tiếp tục)**: Tạo danh sách Trailer sử dụng `ListView.builder`.


* 
**Step 5 – Test and Polish**: Chạy ứng dụng để kiểm tra điều hướng hoạt động và giao diện cuộn mượt mà.


* 
**Step 5 (Tiếp tục)**: Có thể tùy chọn thêm quản lý trạng thái với `setState()` hoặc `ChangeNotifier`.



**4. Expected Result**

* Ứng dụng hiển thị danh sách phim trên trang Home.


* Ứng dụng điều hướng được đến trang chi tiết chứa poster, genres, overview, actions, và trailers.


* Ứng dụng có thể quay lại trang Home bằng nút Back.


* Khớp với trình tự Demo Progress trong Figures 8.12 – 8.18 của cuốn Mastering Flutter 2025.



**5. Submission**

* 
**Deliverable**: Nộp file nén dự án Flutter hoặc link chia sẻ DartPad.


* 
**Tiêu chí đánh giá 1**: Logic điều hướng chính xác (30%).


* 
**Tiêu chí đánh giá 2**: Bố cục UI và tính nhất quán trong thiết kế (30%).


* 
**Tiêu chí đánh giá 3**: Chức năng và xử lý trạng thái (25%).


* 
**Tiêu chí đánh giá 4**: Code rõ ràng và có chú thích (15%).

