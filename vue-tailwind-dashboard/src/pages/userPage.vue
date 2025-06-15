<template>
  <div class="p-6">
    <h1 class="text-3xl font-bold text-gray-800 mb-6">👤 User List</h1>

    <div class="mb-4 max-w-md relative">
      <input
        v-model="searchQuery"
        type="text"
        placeholder="Search users"
        class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring focus:ring-blue-200 pr-10"
      />
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
        <circle cx="11" cy="11" r="7" />
        <line x1="21" y1="21" x2="16.65" y2="16.65" />
      </svg>
    </div>

    <div class="overflow-x-auto">
      <table class="min-w-full bg-white shadow rounded-2xl overflow-hidden">
        <thead class="bg-gray-100 text-gray-700">
          <tr>
            <th class="text-left py-3 px-5">Username</th>
            <th class="text-left py-3 px-5">Email</th>
            <th class="text-left py-3 px-5">Phone</th>
            <th class="text-left py-3 px-5">Role</th>
            <th class="text-left py-3 px-5">Bio</th>
            <th class="text-left py-3 px-5">Avatar</th>
            <th class="text-left py-3 px-5">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="user in filteredUsers"
            :key="user._id"
            class="hover:bg-gray-50 transition duration-200 border-t"
          >
            <td class="py-3 px-5 text-gray-800">{{ user.username }}</td>
            <td class="py-3 px-5 text-gray-600">{{ user.email }}</td>
            <td class="py-3 px-5 text-gray-600">{{ user.phoneNumber }}</td>
            <td class="py-3 px-5">
              <select
                v-model="user.role"
                class="px-2 py-1 border rounded text-sm bg-white"
                @change="updateRole(user)"
              >
                <option value="user">User</option>
                <option value="admin">Admin</option>
              </select>
            </td>
            <td class="py-3 px-5 text-gray-600">{{ user.bio || "–" }}</td>
            <td class="py-3 px-5">
              <img
                :src="user.profilePicture"
                alt="Profile"
                class="w-10 h-10 rounded-full object-cover border"
              />
            </td>
            <td class="py-3 px-5 space-x-2">
              <button
                class="text-blue-600 hover:underline text-sm"
                @click="openEditModal(user)"
              >
                Edit
              </button>
              <button
                class="text-red-600 hover:underline text-sm"
                @click="deleteUser(user._id)"
              >
                Delete
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="!filteredUsers.length" class="text-gray-500 mt-4">
      No users found.
    </div>

    <div
      v-if="showEditModal"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-40"
    >
      <div
        class="bg-white p-6 rounded-2xl shadow-2xl w-full max-w-lg relative transition-all duration-300 ease-in-out"
      >
        <h2
          class="text-2xl font-semibold mb-6 text-gray-800 flex items-center gap-2"
        >
          ✏️ Edit User
        </h2>

        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-600 mb-1"
              >Username</label
            >
            <input
              v-model="editUser.username"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter username"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-600 mb-1"
              >Email</label
            >
            <input
              v-model="editUser.email"
              type="email"
              class="w-full px-4 py-2 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter email"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-600 mb-1"
              >Phone</label
            >
            <input
              v-model="editUser.phoneNumber"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter phone number"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-600 mb-1"
              >Bio</label
            >
            <input
              v-model="editUser.bio"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter bio"
            />
          </div>
        </div>
        <div class="mt-6 flex justify-end space-x-3">
          <button
            class="px-4 py-2 bg-gray-100 text-gray-800 rounded-xl hover:bg-gray-200 transition"
            @click="showEditModal = false"
          >
            Cancel
          </button>
          <button
            class="px-4 py-2 bg-blue-600 text-white font-medium rounded-xl hover:bg-blue-700 transition"
            @click="saveUserEdits"
          >
            Save
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import apiService from "@/services/api.service.js";

export default {
  name: "UserPage",
  data() {
    return {
      users: [],
      searchQuery: "",
      showEditModal: false,
      editUser: {
        _id: "",
        username: "",
        email: "",
        phoneNumber: "",
        bio: "",
      },
    };
  },
  computed: {
    filteredUsers() {
      const query = this.searchQuery.toLowerCase().trim();
      return this.users
        .filter((user) => user.role !== "admin")
        .filter((user) => {
          if (!query) return true;
          return (
            user.username.toLowerCase().includes(query) ||
            (user.email && user.email.toLowerCase().includes(query)) ||
            (user.phoneNumber && user.phoneNumber.toLowerCase().includes(query))
          );
        });
    },
  },
  mounted() {
    this.fetchUsers();
  },
  methods: {
    async fetchUsers() {
      try {
        const response = await apiService.getUsers();
        this.users = response.data;
      } catch (error) {
        console.error("Error fetching users:", error);
      }
    },
    async updateRole(user) {
      try {
        await apiService.updateUserRole(user._id, user.role);
        this.$toast?.success("Role updated");
      } catch (error) {
        console.error("Error updating role:", error);
        this.$toast?.error("Failed to update role");
      }
    },
    async deleteUser(userId) {
      if (confirm("Are you sure you want to delete this user?")) {
        try {
          await apiService.deleteUser(userId);
          this.users = this.users.filter((user) => user._id !== userId);
          this.$toast?.success("User deleted");
        } catch (error) {
          console.error("Error deleting user:", error);
          this.$toast?.error("Failed to delete user");
        }
      }
    },
    openEditModal(user) {
      this.editUser = { ...user };
      this.showEditModal = true;
    },
    async saveUserEdits() {
      try {
        await apiService.updateUser(this.editUser._id, {
          username: this.editUser.username,
          email: this.editUser.email,
          phoneNumber: this.editUser.phoneNumber,
          bio: this.editUser.bio,
        });
        this.showEditModal = false;
        this.$toast?.success("User updated");

        const index = this.users.findIndex((u) => u._id === this.editUser._id);
        if (index !== -1) {
          this.users.splice(index, 1, { ...this.editUser });
        }
      } catch (error) {
        console.error("Error updating user:", error);
        this.$toast?.error("Failed to update user");
      }
    },
  },
};
</script>
