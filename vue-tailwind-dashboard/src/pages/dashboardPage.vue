<template>
  <div class="p-4 bg-gray-50 min-h-screen">
    <div class="mb-4">
      <h1 class="text-4xl font-semibold text-gray-800">📊 Tổng quan</h1>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      <div class="bg-white shadow rounded-lg p-4">
        <h2 class="text-lg font-medium text-gray-600 mb-2">📁 Tổng tài liệu</h2>
        <p class="text-3xl font-bold text-blue-600">{{ documentCount }}</p>
      </div>
      <div class="bg-white shadow rounded-lg p-4">
        <h2 class="text-lg font-medium text-gray-600 mb-2">👥 Người dùng</h2>
        <p class="text-3xl font-bold text-green-600">{{ userCount }}</p>
      </div>
      <div class="bg-white shadow rounded-lg p-4">
        <h2 class="text-lg font-medium text-gray-600 mb-2">
          📅 Cập nhật hôm nay
        </h2>
        <p class="text-3xl font-bold text-purple-600">{{ updateCount }}</p>
      </div>
      <div class="bg-white shadow rounded-lg p-4">
        <h2 class="text-lg font-medium text-gray-600 mb-2">🧑‍🤝‍🧑 Nhóm</h2>
        <p class="text-3xl font-bold text-pink-600">{{ groupCount }}</p>
      </div>
    </div>

    <div class="mt-10 bg-white shadow rounded-lg p-6">
      <h2
        class="text-3xl font-semibold text-gray-800 mb-6 flex items-center space-x-2"
      >
        <span>📈</span>
        <span>Biểu đồ thống kê theo tuần</span>
      </h2>

      <div class="mb-6 flex space-x-6 items-center">
        <label class="flex items-center space-x-2">
          <span>Loại thống kê:</span>
          <select v-model="selectedType" class="border rounded px-2 py-1">
            <option value="documents">Tài liệu</option>
            <option value="users">Người dùng</option>
            <option value="groups">Nhóm</option>
          </select>
        </label>

        <label class="flex items-center space-x-2">
          <span>Chọn tuần:</span>
          <select v-model="selectedWeek" class="border rounded px-2 py-1">
            <option value="all">Tất cả 8 tuần</option>
            <option
              v-for="(label, index) in displayLabels"
              :key="index"
              :value="index"
            >
              {{ label }}
            </option>
          </select>
        </label>
      </div>

      <div style="height: 300px">
        <canvas id="weeklyChart" class="w-full h-full"></canvas>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from "vue";
import axios from "axios";
import Chart from "chart.js/auto";
import dayjs from "dayjs";

const API_BASE_URL = "http://localhost:5000/api";

const documentCount = ref(0);
const userCount = ref(0);
const updateCount = ref(0);
const groupCount = ref(0);

const selectedType = ref("documents");
const selectedWeek = ref("all");

const rawLabels = ref([]);
const displayLabels = ref([]);

const datasets = ref({
  documents: [],
  users: [],
  groups: [],
});

const colors = {
  documents: "#3B82F6",
  users: "#10B981",
  groups: "#EC4899",
};

let chart = null;

async function fetchCounts() {
  try {
    const [docs, users, updates, groups] = await Promise.all([
      axios.get(`${API_BASE_URL}/admin/documents/count`),
      axios.get(`${API_BASE_URL}/admin/users/count`),
      axios.get(`${API_BASE_URL}/admin/updates/today`),
      axios.get(`${API_BASE_URL}/admin/groups/count`),
    ]);
    documentCount.value = docs.data.count ?? 0;
    userCount.value = users.data.count ?? 0;
    updateCount.value = Array.isArray(updates.data)
      ? updates.data.length
      : (updates.data.count ?? 0);
    groupCount.value = groups.data.count ?? 0;
  } catch (error) {
    console.error("Lỗi khi lấy số liệu tổng quan:", error);
  }
}

async function fetchStatistics() {
  try {
    const res = await axios.get(
      `${API_BASE_URL}/admin/statistics?period=weekly`,
    );
    rawLabels.value = res.data.labels || [];
    datasets.value = res.data.datasets || {
      documents: [],
      users: [],
      groups: [],
    };

    generateDisplayLabels();
    selectedWeek.value = "all";
    renderChart();
  } catch (error) {
    console.error("Lỗi khi lấy thống kê:", error);
  }
}

function generateDisplayLabels() {
  const startDate = dayjs("2025-05-12");

  displayLabels.value = rawLabels.value.map((_, index) => {
    const start = startDate.add(index * 7, "day");
    const end = start.add(6, "day");
    return `Tuần ${index + 1} (${start.format("DD/MM")} - ${end.format("DD/MM")})`;
  });
}

function renderChart() {
  if (!rawLabels.value.length || !datasets.value[selectedType.value]) return;

  const ctx = document.getElementById("weeklyChart").getContext("2d");

  if (chart) {
    chart.destroy();
  }

  let chartLabels = rawLabels.value;
  let chartData = datasets.value[selectedType.value];

  if (selectedWeek.value !== "all") {
    const idx = parseInt(selectedWeek.value);
    if (!isNaN(idx) && idx >= 0 && idx < rawLabels.value.length) {
      chartLabels = [rawLabels.value[idx]];
      chartData = [datasets.value[selectedType.value][idx]];
    }
  }

  chart = new Chart(ctx, {
    type: "bar",
    data: {
      labels: chartLabels,
      datasets: [
        {
          label:
            selectedType.value === "documents"
              ? "Tài liệu"
              : selectedType.value === "users"
                ? "Người dùng"
                : "Nhóm",
          data: chartData,
          backgroundColor: colors[selectedType.value],
          borderRadius: 6,
          barThickness: 40,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        y: {
          beginAtZero: true,
          ticks: { stepSize: 1 },
          title: { display: true, text: "Số lượng" },
        },
        x: {
          title: { display: true, text: "Tuần" },
        },
      },
      plugins: {
        legend: { display: false },
        tooltip: { enabled: true },
      },
    },
  });
}

onMounted(async () => {
  await fetchCounts();
  await fetchStatistics();
});

watch([selectedType, selectedWeek], () => {
  renderChart();
});
</script>
