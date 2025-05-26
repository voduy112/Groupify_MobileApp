<template>
  <div class="p-4">
    <h1 class="text-xl font-bold mb-4">User Page</h1>

    <table class="min-w-full bg-white shadow rounded-lg">
      <thead class="bg-gray-100">
        <tr>
          <th class="text-left py-2 px-4">Username</th>
          <th class="text-left py-2 px-4">Email</th>
          <th class="text-left py-2 px-4">Phone</th>
          <th class="text-left py-2 px-4">Role</th>
          <th class="text-left py-2 px-4">Bio</th>
          <th class="text-left py-2 px-4">Profile Picture</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="user in users" :key="user.email" class="border-t">
          <td class="py-2 px-4">{{ user.username }}</td>
          <td class="py-2 px-4">{{ user.email }}</td>
          <td class="py-2 px-4">{{ user.phoneNumber }}</td>
          <td class="py-2 px-4">{{ user.role }}</td>
          <td class="py-2 px-4">{{ user.bio }}</td>
          <td class="py-2 px-4">
            <img :src="user.profilePicture" alt="Profile" class="w-10 h-10 rounded-full object-cover" />
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import apiService from '@/services/api.service.js';

export default {
  data() {
    return {
      users: [],
    };
  },
  methods: {
    async fetchUsers() {
      try {
        const response = await apiService.getUsers();
        this.users = response.data;
      } catch (error) {
        console.error('Error fetching users:', error);
      }
    },
  },
  mounted() {
    this.fetchUsers();
  },
};
</script>
