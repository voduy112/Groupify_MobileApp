<template>
  <div class="p-6">
    <h1 class="text-3xl font-bold text-gray-800 mb-6">
      📁 Group List
    </h1>

    <div class="mb-6 max-w-md relative">
      <input
        v-model="searchQuery"
        type="text"
        placeholder="Search groups"
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
      v-if="filteredGroups.length"
      class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
    >
      <div
        v-for="group in filteredGroups"
        :key="group._id"
        class="bg-white rounded-2xl shadow border border-gray-200 p-6 hover:shadow-lg transition-shadow flex flex-col justify-between"
      >
        <img
          :src="getGroupImage(group.imgGroup)"
          alt="Ảnh nhóm"
          class="w-full h-40 object-cover rounded-xl mb-4"
        >

        <div class="flex items-start justify-between mb-4">
          <h2 class="text-xl font-bold text-gray-800">
            {{ group.name }}
          </h2>
          <div class="space-x-2 text-sm">
            <button
              class="text-blue-600 hover:underline"
              @click="viewGroupMembers(group)"
            >
              👁 Xem
            </button>
            <button
              class="text-yellow-600 hover:underline"
              @click="openEditModal(group)"
            >
              Sửa
            </button>
            <button
              class="text-red-600 hover:underline"
              @click="confirmDelete(group._id)"
            >
              Xóa
            </button>
          </div>
        </div>

        <p class="text-left text-gray-700 font-medium mb-2">
          {{ group.description || "—" }}
        </p>
        <p class="text-left text-sm text-gray-600 mb-1">
          Tổng thành viên: {{ group.membersID?.length ?? 0 }}
        </p>
        <p class="text-left text-sm text-gray-600 mb-1">
          Người tạo: {{ group.ownerId?.username || "Không rõ" }}
        </p>
        <div class="text-left text-sm text-gray-500">
          <p>
            <span class="font-medium">Ngày tạo:</span>
            {{ formatDate(group.createDate) }}
          </p>
        </div>
      </div>
    </div>

    <div
      v-else
      class="text-gray-500 mt-4"
    >
      Không tìm thấy nhóm nào.
    </div>

    <div
      v-if="selectedGroup"
      class="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50"
    >
      <div class="bg-white p-6 rounded-xl shadow-lg w-full max-w-md">
        <h3 class="text-xl font-bold mb-4">
          Sửa nhóm
        </h3>
        <label class="block mb-2">
          <span class="text-gray-700">Tên nhóm</span>
          <input
            v-model="selectedGroup.name"
            class="w-full border p-2 rounded"
          >
        </label>
        <label class="block mb-2">
          <span class="text-gray-700">Mô tả</span>
          <textarea
            v-model="selectedGroup.description"
            class="w-full border p-2 rounded"
          />
        </label>
        <div class="flex justify-end mt-4 space-x-2">
          <button
            class="px-4 py-2 bg-gray-300 rounded"
            @click="selectedGroup = null"
          >
            Hủy
          </button>
          <button
            class="px-4 py-2 bg-blue-600 text-white rounded"
            @click="saveGroup"
          >
            Lưu
          </button>
        </div>
      </div>
    </div>

    <div
      v-if="viewingGroup"
      class="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50"
    >
      <div class="bg-white p-6 rounded-xl shadow-lg w-full max-w-md">
        <h3 class="text-xl font-bold mb-4">
          Thành viên nhóm: {{ viewingGroup.name }}
        </h3>
        <ul
          class="list-disc list-inside mb-4 max-h-64 overflow-y-auto font-mono pl-2 space-y-1 text-sm text-gray-700"
        >
          <li
            v-if="!viewingGroup.membersID?.length"
            class="text-gray-500 font-sans"
          >
            Không có thành viên.
          </li>
          <li
            v-for="member in viewingGroup.membersID"
            :key="member._id"
          >
            {{ member.username }}
          </li>
        </ul>
        <div class="text-right">
          <button
            class="px-4 py-2 bg-gray-300 rounded"
            @click="viewingGroup = null"
          >
            Đóng
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";

export default {
  name: "GroupList",
  data() {
    return {
      groups: [],
      selectedGroup: null,
      viewingGroup: null,
      searchQuery: "",
    };
  },
  computed: {
    filteredGroups() {
      const q = this.searchQuery.toLowerCase().trim();
      if (!q) return this.groups;
      return this.groups.filter((group) => {
        return (
          group.name.toLowerCase().includes(q) ||
          (group.description && group.description.toLowerCase().includes(q))
        );
      });
    },
  },
  async mounted() {
    try {
      await this.fetchGroups();
    } catch (err) {
      console.error("Lỗi khi tải danh sách nhóm:", err);
    }
  },
  methods: {
    async fetchGroups() {
      try {
        const res = await axios.get("https://groupifymobileapp-production.up.railway.app/api/admin/groups");
        this.groups = res.data;
      } catch (err) {
        console.error("Không thể tải nhóm", err);
        this.groups = [];
      }
    },
    async viewGroupMembers(group) {
      try {
        const res = await axios.get(
          `https://groupifymobileapp-production.up.railway.app/api/group/${group._id}`,
        );
        this.viewingGroup = res.data;
      } catch (err) {
        console.error("Không thể tải thành viên nhóm", err);
        this.viewingGroup = null;
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
    openEditModal(group) {
      this.selectedGroup = { ...group };
    },
    async saveGroup() {
      try {
        await axios.put(
          `https://groupifymobileapp-production.up.railway.app/api/admin/groups/${this.selectedGroup._id}`,
          this.selectedGroup,
        );
        await this.fetchGroups();
        this.selectedGroup = null;
      } catch (err) {
        console.error("Không thể cập nhật nhóm", err);
      }
    },
    confirmDelete(id) {
      if (confirm("Bạn có chắc chắn muốn xóa nhóm này không?")) {
        this.deleteGroup(id);
      }
    },
    async deleteGroup(id) {
      try {
        await axios.delete(`https://groupifymobileapp-production.up.railway.app/api/admin/groups/${id}`);
        this.groups = this.groups.filter((group) => group._id !== id);
      } catch (err) {
        console.error("Không thể xóa nhóm", err);
        alert("Xóa thất bại. Vui lòng thử lại.");
      }
    },
    getGroupImage(imgGroup) {
      if (!imgGroup || imgGroup === "default.jpg") {
        return "https://via.placeholder.com/400x200?text=No+Image";
      }
      return imgGroup;
    },
  },
};
</script>
