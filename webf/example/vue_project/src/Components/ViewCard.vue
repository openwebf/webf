<template>
  <div class="card" @click="handleCardClick">
    <div class="image-container">
      <img :src="src" alt="Image not loaded" class="image" />
    </div>
    <div class="card-footer">
      <h3 class="card-title">{{ title }}</h3>
      <p class="card-description">{{ desc }}</p>
    </div>
  </div>
</template>

<style scoped>
.card {
  width: 95%;
  margin: 15px auto 0;
  border: 1px solid red;
  background-color: var(--background-color);
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  font-family: 'Arial', sans-serif;
}

/* Tablet and larger screens */
@media (min-width: 768px) {
  .card {
    width: 45%;
  }
}

.image-container {
  background-color: #2e2e3e;
}

.image {
  width: 100%;
}

.card-footer {
  margin-top: 20px;
  padding: 16px;
  /* text-align: center; */
}

.card-title {
  font-size: 20px;
  color: var(--font-color);
  margin: 0 0 8px 0;
}

.card-description {
  font-size: 14px;
  margin: 0;
  color: #aaa;
}
</style>

<script>
export default {
  props: {
    title: String,
    desc: {
      type: String,
      required: true
    },
    src: String,
    href: String
  },
  methods: {
    handleCardClick() {
      console.log('click', this.$props.href);
      window.webf.hybridHistory.pushState({}, this.$props.href);
    }
  }
}
</script>