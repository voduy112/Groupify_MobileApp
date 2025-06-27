<template>
  <div class="max-w-5xl mx-auto px-6 py-10">
    <div
      v-if="loading"
      class="flex items-center justify-center text-gray-500 text-base h-40"
    >
      <span class="animate-pulse">Đang tải thông tin người dùng...</span>
    </div>

    <div
      v-else-if="isAdmin"
      class="bg-white border border-gray-200 rounded-2xl shadow-md p-8 space-y-6"
    >
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-2xl font-semibold text-gray-800">
            🔐 Access Control
          </h1>
          <p class="text-sm text-gray-500">
            Quản lý quyền truy cập cho Admin
          </p>
        </div>
        <button
          class="text-sm bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-lg transition"
          @click="logout"
        >
          Đăng xuất
        </button>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-gray-700 text-sm">
        <div class="p-4 bg-gray-50 rounded-lg border">
          👤 Xin chào: <span class="font-semibold">{{ user.username }}</span>
        </div>
        <div class="p-4 bg-gray-50 rounded-lg border">
          🛡️ Vai trò:
          <span class="font-semibold capitalize">{{ user.role }}</span>
        </div>
      </div>

      <div
        class="p-5 bg-blue-50 border border-blue-200 rounded-xl text-blue-800"
      >
        <h2 class="text-base font-medium mb-2">
          📂 Quản lý nhóm
        </h2>
        <p class="text-sm mb-2">
          Bạn có thể xem, tạo và chỉnh sửa nhóm người dùng.
        </p>
        <router-link
          to="/group"
          class="inline-block text-sm font-semibold text-blue-600 hover:underline"
        >
          → Đi tới quản lý nhóm
        </router-link>
      </div>
    </div>

    <div
      v-else
      class="bg-white border border-gray-200 rounded-2xl shadow-md p-10 text-center text-gray-700"
    >
      <h2 class="text-xl font-semibold mb-2">
        🚫 Truy cập bị từ chối
      </h2>
      <p class="mb-4 text-sm text-gray-500">
        Trang này chỉ dành cho người có quyền admin. Vui lòng đăng nhập lại.
      </p>
      <router-link
        to="/login"
        class="inline-block bg-gray-800 text-white px-5 py-2 rounded-lg text-sm hover:bg-gray-700 transition"
      >
        ← Quay lại đăng nhập
      </router-link>
    </div>
  </div>
</template>

<script>
export default {
  name: "AccessControl",
  data() {
    return {
      user: null,
      isAdmin: false,
      loading: true,
    };
  },
  beforeMount() {
    const storedUser = localStorage.getItem("user");
    if (storedUser) {
      try {
        this.user = JSON.parse(storedUser);
        this.isAdmin = this.user.role === "admin";
      } catch {
        this.user = null;
        this.isAdmin = false;
      }
    }
    this.loading = false;
  },
  methods: {
    logout() {
      if (confirm("Bạn có chắc muốn đăng xuất?")) {
        localStorage.removeItem("user");
        this.$router.push("/login");
      }
    },
  },
};
</script>

<style scoped></style>
