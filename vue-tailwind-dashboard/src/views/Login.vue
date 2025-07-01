<template>
  <div class="min-h-screen flex flex-col items-center justify-center bg-blue-50 px-4">
    <h1 class="text-4xl font-extrabold text-blue-800 mb-8 leading-tight font-sans text-center drop-shadow-md">
      Đăng nhập Admin
    </h1>

    <div class="bg-white p-8 rounded-lg shadow-lg w-full max-w-sm">
      <form @submit.prevent="handleLogin" class="space-y-6">
        <input v-model="email" type="email" required placeholder="Email"
          class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-600 text-base placeholder-gray-500 text-gray-900" />

        <input v-model="password" type="password" required placeholder="Mật khẩu"
          class="w-full px-4 py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-600 text-base placeholder-gray-500 text-gray-900" />

        <button type="submit"
          class="w-full bg-blue-700 hover:bg-blue-800 text-white font-bold text-lg py-3 rounded-md transition duration-200">
          Đăng nhập
        </button>
      </form>

      <p v-if="errorMessage" class="mt-4 text-center text-red-600 font-medium">
        {{ errorMessage }}
      </p>
    </div>
  </div>
</template>

<script>
import { ref } from "vue";
import { useRouter } from "vue-router";
import { login } from "@/services/auth";

export default {
  name: "AdminLogin",
  setup() {
    const email = ref("");
    const password = ref("");
    const errorMessage = ref("");
    const router = useRouter();

    const handleLogin = async () => {
      errorMessage.value = "";
      try {
        const res = await login(email.value, password.value);
        if (res.success && res.data?.accessToken) {
          localStorage.setItem("token", res.data.accessToken);
          router.push("/");
        } else {
          errorMessage.value = res.message || "Đăng nhập không thành công.";
        }
      } catch (error) {
        errorMessage.value = "Lỗi hệ thống, vui lòng thử lại sau.";
      }
    };

    return {
      email,
      password,
      errorMessage,
      handleLogin,
    };
  },
};
</script>
