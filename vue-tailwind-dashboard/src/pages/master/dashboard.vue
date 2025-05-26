<template>
  <div class="h-screen flex">
    <!-- Sidebar -->
    <div class="w-56 bg-gray-900 text-white flex flex-col">
      <!-- Logo / Title -->
      <div class="h-12 flex items-center px-4 bg-gray-800">
        <h3 class="font-bold text-lg">Admin Dashboard</h3>
      </div>

      <!-- Navigation Links -->
      <div class="flex-1 overflow-y-auto px-4 py-4 space-y-2">
        <!-- User -->
        <router-link to="/user" class="flex items-center py-2 px-2 rounded-md text-white hover:bg-gray-700">
          <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 24 24">
            <path
              d="M12 12c2.7 0 5-2.3 5-5s-2.3-5-5-5-5 2.3-5 5 2.3 5 5 5zm0 2c-3.3 0-10 1.7-10 5v3h20v-3c0-3.3-6.7-5-10-5z" />
          </svg>
          User
        </router-link>

        <!-- Group -->
        <router-link to="/group" class="flex items-center py-2 px-2 rounded-md text-white hover:bg-gray-700">
          <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 24 24">
            <path
              d="M16 11c1.7 0 3-1.3 3-3s-1.3-3-3-3-3 1.3-3 3 1.3 3 3 3zm-8 0c1.7 0 3-1.3 3-3S9.7 5 8 5 5 6.3 5 8s1.3 3 3 3zm0 2c-2.3 0-7 1.2-7 3.5V19h14v-2.5c0-2.3-4.7-3.5-7-3.5zm8 0c-.3 0-.7 0-1 .1 1.2.9 2 2.1 2 3.4V19h6v-2.5c0-2.3-4.7-3.5-7-3.5z" />
          </svg>
          Group
        </router-link>

        <!-- Document -->
        <router-link to="/document" class="flex items-center py-2 px-2 rounded-md text-white hover:bg-gray-700">
          <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 24 24">
            <path d="M6 2h9l5 5v13a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2zm8 7V3.5L18.5 9H14z" />
          </svg>
          Document
        </router-link>

        <!-- Quiz -->
        <router-link to="/quiz" class="flex items-center py-2 px-2 rounded-md text-white hover:bg-gray-700">
          <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 24 24">
            <path
              d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10 10-4.5 10-10S17.5 2 12 2zm1 17h-2v-2h2v2zm1.1-7.75c-.8.6-1.1 1.1-1.1 1.75h-2c0-1.2.6-2.1 1.5-2.8.6-.4 1.1-.9 1.1-1.7 0-1-.9-1.8-2-1.8s-2 .8-2 1.8H8c0-2.2 1.8-3.8 4-3.8s4 1.6 4 3.8c0 1.3-.6 2-1.9 2.85z" />
          </svg>
          Quiz
        </router-link>
        <!-- Access Control -->
        <router-link to="/access-control" class="flex items-center py-2 px-2 rounded-md text-white hover:bg-gray-700">
          <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 24 24">
            <path
              d="M12 2a10 10 0 100 20 10 10 0 000-20zm1 15h-2v-2h2v2zm1.1-7.75c-.8.6-1.1 1.1-1.1 1.75h-2c0-1.2.6-2.1 1.5-2.8.6-.4 1.1-.9 1.1-1.7 0-1-.9-1.8-2-1.8s-2 .8-2 1.8H8c0-2.2 1.8-3.8 4-3.8s4 1.6 4 3.8c0 1.3-.6 2-1.9 2.85z" />
          </svg>
          Access Control
        </router-link>

      </div>
    </div>

    <!-- Main Content -->
    <div class="flex-1 flex flex-col bg-gray-100">
      <!-- Header -->
      <div class="h-12 bg-white flex items-center justify-between px-4 shadow-sm">
        <!-- Menu Icon -->
        <div class="text-xl cursor-pointer">
          <svg class="w-6 h-6 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </div>

        <!-- Search -->
        <div class="flex-grow max-w-md mx-4">
          <div class="relative">
            <input type="text" placeholder="Search..."
              class="w-full py-1.5 pl-10 pr-10 rounded-lg border border-gray-300 focus:outline-none focus:ring focus:ring-blue-200" />
            <!-- Search Icon -->
            <div class="absolute left-3 inset-y-0 flex items-center text-gray-400">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </div>
            <!-- Microphone Icon -->
            <div class="absolute right-3 inset-y-0 flex items-center text-gray-400 cursor-pointer">
              <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path
                  d="M12 14a3 3 0 0 0 3-3V5a3 3 0 0 0-6 0v6a3 3 0 0 0 3 3zm5-3a5 5 0 0 1-10 0H5a7 7 0 0 0 14 0h-2zm-5 7a7.002 7.002 0 0 0 6.93-6H18a5 5 0 0 1-10 0H5.07A7.002 7.002 0 0 0 12 18z" />
              </svg>
            </div>
          </div>
        </div>

        <!-- User Info -->
        <div class="relative">
          <button @click="toggleUserMenu"
            class="flex items-center gap-3 px-2 py-1 rounded-md hover:bg-gray-100 transition focus:outline-none">
            <div
              class="w-10 h-10 rounded-full bg-gray-900 text-white flex items-center justify-center text-sm font-semibold shadow">
              .DEV
            </div>
            <div class="text-left leading-tight">
              <div class="text-sm font-semibold text-gray-800">Dev</div>
              <div class="text-xs text-gray-500">Administrator</div>
            </div>
          </button>
          <div v-if="showUserMenu"
            class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg z-50 overflow-hidden border border-gray-100">
            <a href="#"
              class="block w-full px-4 py-2 text-sm text-center text-gray-700 hover:bg-gray-100 transition-colors">Settings</a>
            <a href="#"
              class="block w-full px-4 py-2 text-sm text-center text-gray-700 hover:bg-gray-100 transition-colors">Support</a>
            <button @click="signOut"
              class="block w-full px-4 py-2 text-sm text-center text-red-600 hover:bg-red-50 transition-colors">Signout</button>
          </div>
        </div>
      </div>

      <!-- Nội dung động hiển thị ở đây -->
      <div class="flex-1 p-4 overflow-auto">
        <router-view />
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "DashboardView",
  data() {
    return {
      showUserMenu: false,
    };
  },
  methods: {
    toggleUserMenu() {
      this.showUserMenu = !this.showUserMenu;
    },
    signOut() {
      console.log("Signing out...");
    },
  },
};
</script>
