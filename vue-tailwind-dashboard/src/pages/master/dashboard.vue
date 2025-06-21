<template>
  <div class="h-screen flex">
    <div class="w-56 bg-gray-900 text-white flex flex-col">
      <div class="h-12 flex items-center px-4 bg-gray-800">
        <h3 class="font-bold text-lg">
          Admin Dashboard
        </h3>
      </div>

      <div class="flex-1 overflow-y-auto px-4 py-4 space-y-2">
        <router-link
          to="/dashboard"
          class="flex items-center py-2 px-2 rounded-md text-white hover:bg-gray-700"
        >
          <svg
            class="w-5 h-5 mr-2"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            viewBox="0 0 24 24"
          >
            <path
              d="M3 12h3v8H3v-8zm5-4h3v12H8V8zm5-2h3v14h-3V6zm5 6h3v8h-3v-8z"
            />
          </svg>
          Overview
        </router-link>

        <router-link
          to="/user"
          class="flex items-center py-2 px-2 rounded-md text-white hover:bg-gray-700"
        >
          <svg
            class="w-5 h-5 mr-2"
            fill="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              d="M12 12c2.7 0 5-2.3 5-5s-2.3-5-5-5-5 2.3-5 5 2.3 5 5 5zm0 2c-3.3 0-10 1.7-10 5v3h20v-3c0-3.3-6.7-5-10-5z"
            />
          </svg>
          User
        </router-link>

        <router-link
          to="/group"
          class="flex items-center py-2 px-2 rounded-md text-white hover:bg-gray-700"
        >
          <svg
            class="w-5 h-5 mr-2"
            fill="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              d="M16 11c1.7 0 3-1.3 3-3s-1.3-3-3-3-3 1.3-3 3 1.3 3 3 3zm-8 0c1.7 0 3-1.3 3-3S9.7 5 8 5 5 6.3 5 8s1.3 3 3 3zm0 2c-2.3 0-7 1.2-7 3.5V19h14v-2.5c0-2.3-4.7-3.5-7-3.5zm8 0c-.3 0-.7 0-1 .1 1.2.9 2 2.1 2 3.4V19h6v-2.5c0-2.3-4.7-3.5-7-3.5z"
            />
          </svg>
          Group
        </router-link>

        <router-link
          to="/document"
          class="flex items-center py-2 px-2 rounded-md text-white hover:bg-gray-700"
        >
          <svg
            class="w-5 h-5 mr-2"
            fill="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              d="M6 2h9l5 5v13a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2zm8 7V3.5L18.5 9H14z"
            />
          </svg>
          Document
        </router-link>
        <router-link
          to="/report"
          class="flex items-center py-2 px-2 rounded-md text-white hover:bg-gray-700"
        >
          <svg
            class="w-5 h-5 mr-2"
            fill="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              d="M3 3h18v2H3V3zm0 4h18v13H3V7zm4 3h2v7H7v-7zm4 0h2v7h-2v-7zm4 0h2v7h-2v-7z"
            />
          </svg>
          Report
        </router-link>

        <router-link
          to="/access-control"
          class="flex items-center py-2 px-2 rounded-md text-white hover:bg-gray-700"
        >
          <svg
            class="w-5 h-5 mr-2"
            fill="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              d="M12 2a10 10 0 100 20 10 10 0 000-20zm1 15h-2v-2h2v2zm1.1-7.75c-.8.6-1.1 1.1-1.1 1.75h-2c0-1.2.6-2.1 1.5-2.8.6-.4 1.1-.9 1.1-1.7 0-1-.9-1.8-2-1.8s-2 .8-2 1.8H8c0-2.2 1.8-3.8 4-3.8s4 1.6 4 3.8c0 1.3-.6 2-1.9 2.85z"
            />
          </svg>
          Access Control
        </router-link>
      </div>
    </div>

    <div class="flex-1 flex flex-col bg-gray-100">
      <div
        class="h-12 bg-white flex items-center justify-between px-4 shadow-sm"
      >
        <div class="text-xl cursor-pointer w-6 h-6" />

        <div class="relative">
          <button
            class="flex items-center gap-3 px-2 py-1 rounded-md hover:bg-gray-100 transition focus:outline-none"
            @click="toggleUserMenu"
          >
            <div
              class="w-10 h-10 rounded-full bg-gray-900 text-white flex items-center justify-center text-sm font-semibold shadow"
            >
              .DEV
            </div>
            <div class="text-left leading-tight">
              <div class="text-sm font-semibold text-gray-800">
                {{ username }}
              </div>
              <div class="text-xs text-gray-500">
                Administrator
              </div>
            </div>
          </button>

          <div
            v-if="showUserMenu"
            class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg z-50 overflow-hidden border border-gray-100"
          >
            <button
              class="block w-full px-4 py-2 text-sm text-center text-red-600 hover:bg-red-50 transition-colors"
              @click="signOut"
            >
              Signout
            </button>
          </div>
        </div>
      </div>

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
      username: localStorage.getItem("username") || "Dev",
    };
  },
  methods: {
    toggleUserMenu() {
      this.showUserMenu = !this.showUserMenu;
    },
    signOut() {
      localStorage.clear();
      this.$router.push("/login");
    },
  },
};
</script>
