![image](https://github.com/user-attachments/assets/ddb258c9-c31c-4476-b03a-04cdc6304fb7)# Groupify_MobileApp

**Groupify_MobileApp** là một hệ sinh thái ứng dụng quản lý nhóm học tập, bao gồm:

- Ứng dụng di động (Flutter)
- Backend API (Node.js/Express)
- Dashboard quản trị (Vue.js + TailwindCSS)

## Mục lục

- [Kiến trúc tổng quan](#kiến-trúc-tổng-quan)
- [Hướng dẫn cài đặt & chạy từng thành phần](#hướng-dẫn-cài-đặt--chạy-từng-thành-phần)
  - [1. Mobile App (Flutter)](#1-mobile-app-flutter)
  - [2. Backend API (Nodejsexpress)](#2-backend-api-nodejsexpress)
  - [3. Dashboard (Vue.js + TailwindCSS)](#3-dashboard-vuejs--tailwindcss)
- [Liên hệ & đóng góp](#liên-hệ--đóng-góp)

---

## Kiến trúc tổng quan

```
Groupify_MobileApp/
│
├── app/                   # Ứng dụng di động Flutter
├── api/                   # Backend Node.js/Express (REST API, WebSocket)
├── vue-tailwind-dashboard/ # Dashboard quản trị (Vue.js + TailwindCSS)
└── ...
```

- **app/**: Ứng dụng di động, hỗ trợ đa nền tảng (Android, iOS, Web, Desktop).
- **api/**: Backend RESTful API, quản lý dữ liệu nhóm, người dùng, tài liệu, ... (MongoDB, Socket.io, Cloudinary, ...).
- **vue-tailwind-dashboard/**: Dashboard web cho admin/giáo viên quản lý nhóm, người dùng, thống kê.

---

## Hướng dẫn cài đặt & chạy từng thành phần

### 1. Mobile App (Flutter)

**Yêu cầu:**

- Flutter SDK (>=3.x)
- Dart SDK

**Cài đặt & chạy:**

```bash
cd app
flutter pub get
flutter run
```

> Có thể chạy trên Android/iOS/Web/Windows/Mac/Linux tùy thiết bị.

---

### 2. Backend API (Node.js/Express)

**Yêu cầu:**

- Node.js >= 16.x
- MongoDB (local hoặc cloud)
- Tạo file `.env` theo mẫu `.env.example` (nếu có)

**Cài đặt & chạy:**

```bash
cd api
npm install
npm start
```

> Server sẽ chạy mặc định trên cổng 3000 (hoặc theo cấu hình).

---

### 3. Dashboard (Vue.js + TailwindCSS)

**Yêu cầu:**

- Node.js >= 16.x

**Cài đặt & chạy:**

```bash
cd vue-tailwind-dashboard
npm install
npm run serve
```

> Dashboard sẽ chạy trên cổng 8080 (hoặc theo cấu hình).

---

## Liên hệ & đóng góp

- Đóng góp code, báo lỗi hoặc ý tưởng mới qua GitHub Pull Request/Issue.
- Liên hệ nhóm phát triển qua email hoặc các kênh liên lạc nội bộ.

---

**Chúc bạn sử dụng và phát triển hệ thống Groupify_MobileApp hiệu quả!**

## Deployment

| Thành phần         | Link Production/Demo                | Ghi chú                |
|--------------------|-------------------------------------|------------------------|
| Mobile App (Flutter) | https://drive.google.com/drive/folders/1f2BDn86rETlZ-laRVSgIkR14aictSpcL?usp=sharing | Có thể build APK |
| Backend API        | [https://groupifymobileapp-production.up.railway.app](https://groupifymobileapp-production.up.railway.app) | REST API server |
| Dashboard          | [https://groupifyad.netlify.app/login](https://groupifyad.netlify.app/login) | Dashboard quản trị |

![image](https://github.com/user-attachments/assets/45832e30-7dc4-4885-a9cc-da628810450b)

