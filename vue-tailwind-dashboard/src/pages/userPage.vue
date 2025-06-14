<template>
  <div class="p-6">
    <h1 class="text-3xl font-bold text-gray-800 mb-6">👤 User List</h1>

    <div class="mb-4 max-w-md relative">
      <input
        type="text"
        v-model="searchQuery"
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
                @change="updateRole(user)"
                class="px-2 py-1 border rounded text-sm bg-white"
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
                @click="deleteUser(user._id)"
                class="text-red-600 hover:underline text-sm"
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
  },
  mounted() {
    this.fetchUsers();
  },
};
</script>
