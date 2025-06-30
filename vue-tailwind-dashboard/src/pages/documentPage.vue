<template>
  <div class="p-6">
    <h1 class="text-3xl font-bold text-gray-800 mb-6">
      📄 Document List
    </h1>

    <div class="mb-6 max-w-md relative">
      <input
        v-model="searchQuery"
        type="text"
        placeholder="Search by title..."
        class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring focus:ring-blue-200 pr-10"
      >
      <svg
        class="w-5 h-5 text-gray-400 absolute right-3 top-1/2 transform -translate-y-1/2 pointer-events-none"
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        viewBox="0 0 24 24"
      >
        <circle
          cx="11"
          cy="11"
          r="7"
        />
        <line
          x1="21"
          y1="21"
          x2="16.65"
          y2="16.65"
        />
      </svg>
    </div>

    <div
      v-if="filteredDocuments.length"
      class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
    >
      <div
        v-for="doc in filteredDocuments"
        :key="doc._id"
        class="bg-white rounded-2xl shadow-md p-6 hover:shadow-lg transition-shadow text-left"
      >
        <div class="flex items-center justify-between mb-2">
          <h2 class="text-xl font-semibold text-gray-800">
            {{ doc.title }}
          </h2>
          <div class="flex gap-3 items-center">
            <button
              class="text-sm text-blue-500 hover:underline"
              @click="viewDocument(doc)"
            >
              Xem
            </button>
            <button
              class="text-sm text-red-500 hover:underline"
              @click="confirmDelete(doc._id)"
            >
              Xóa
            </button>
          </div>
        </div>

        <img
          v-if="doc.imgDocument"
          :src="doc.imgDocument"
          alt="Document Image"
          class="w-full max-h-48 object-cover rounded-lg border mb-3"
        >

        <p class="text-gray-600 mb-3">
          {{ doc.description }}
        </p>
        <div class="text-sm text-gray-500">
          <span class="font-medium">Người tạo:</span>
          {{ doc.createdByName || "Không rõ" }}<br>
          <span class="font-medium">Ngày tạo:</span>
          {{ formatDate(doc.createdAt) }}
        </div>
      </div>
    </div>

    <div
      v-else
      class="text-gray-500 mt-4"
    >
      Không tìm thấy tài liệu.
    </div>
  </div>
</template>
<script>
import axios from "axios";

export default {
  name: "DocumentPage",
  data() {
    return {
      documents: [],
      users: [],
      searchQuery: "",
    };
  },
  computed: {
    filteredDocuments() {
      const q = this.searchQuery.toLowerCase().trim();
      if (!q) return this.documents;
      return this.documents.filter((doc) =>
        doc.title.toLowerCase().includes(q),
      );
    },
  },
  mounted() {
    this.initData();
  },
  methods: {
    async initData() {
      try {
        const [usersRes, docsRes] = await Promise.all([
          axios.get("https://groupifymobileapp-production.up.railway.app/api/admin/users"),
          axios.get("https://groupifymobileapp-production.up.railway.app/api/document"),
        ]);

        this.users = usersRes.data;

        this.documents = docsRes.data.documents.map((doc) => {
          let createdByName = "Không rõ";

          if (
            doc.uploaderId &&
            typeof doc.uploaderId === "object" &&
            doc.uploaderId.username
          ) {
            createdByName = doc.uploaderId.username;
          } else if (typeof doc.uploaderId === "string") {
            const user = this.users.find((u) => u._id === doc.uploaderId);
            if (user) createdByName = user.username;
          }

          return {
            ...doc,
            createdByName,
          };
        });
      } catch (err) {
        console.error("Lỗi khi tải dữ liệu:", err);
        this.users = [];
        this.documents = [];
      }
    },

    formatDate(dateStr) {
      if (!dateStr) return "Không rõ";
      const d = new Date(dateStr);
      if (isNaN(d)) return "Không rõ";
      return d.toLocaleDateString("vi-VN", {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
      });
    },

    confirmDelete(id) {
      if (confirm("Bạn có chắc chắn muốn xóa tài liệu này không?")) {
        this.deleteDocument(id);
      }
    },

    deleteDocument(id) {
      axios
        .delete(`https://groupifymobileapp-production.up.railway.app/api/document/${id}`)
        .then(() => {
          this.documents = this.documents.filter((doc) => doc._id !== id);
        })
        .catch((err) => {
          console.error("Xóa tài liệu thất bại", err);
          alert("Không thể xóa tài liệu. Vui lòng thử lại.");
        });
    },

    viewDocument(doc) {
      if (doc.mainFile) {
        window.open(doc.mainFile, "_blank");
      } else {
        alert("Tài liệu này không có file đính kèm.");
      }
    },
  },
};
</script>
