<template>
  <div id="main">
    <!-- Use ListSection for proper styling, padding, and dividers -->
    <flutter-cupertino-list-section header="Basic List Tiles">
      
      <flutter-cupertino-list-tile @click="logClick('Simple Tile')">
        Simple Title
      </flutter-cupertino-list-tile>

      <flutter-cupertino-list-tile @click="logClick('Tile with Subtitle')">
        Title
        <span slotName="subtitle">Subtitle</span>
      </flutter-cupertino-list-tile>

      <flutter-cupertino-list-tile @click="logClick('Tile with Leading Icon')">
        <flutter-cupertino-icon 
          slotName="leading" 
          type="heart_fill" 
          style="color: red; font-size: 22px;"
        ></flutter-cupertino-icon>
        Title with Leading Icon
      </flutter-cupertino-list-tile>

      <flutter-cupertino-list-tile show-chevron="true" @click="logClick('Tile with Chevron')">
        Title with Chevron
      </flutter-cupertino-list-tile>

      <flutter-cupertino-list-tile @click="logClick('Tile with Trailing Info')">
        Title
        <span slotName="additionalInfo">Details</span>
         <!-- Add chevron manually if needed with additionalInfo -->
        <flutter-cupertino-icon 
          slotName="trailing" 
          type="right_chevron" 
          style="color: grey; font-size: 18px;"
        ></flutter-cupertino-icon>
      </flutter-cupertino-list-tile>

      <flutter-cupertino-list-tile @click="logClick('Full Tile')">
         <flutter-cupertino-icon 
          slotName="leading" 
          type="star_fill" 
          style="color: gold; font-size: 22px;"
        ></flutter-cupertino-icon>
        Title
        <span slotName="subtitle">Subtitle explaining the item</span>
        <span slotName="additionalInfo">More info</span>
        <flutter-cupertino-switch slotName="trailing" />
      </flutter-cupertino-list-tile>

    </flutter-cupertino-list-section>

    <flutter-cupertino-list-section header="Notched List Tiles" inset-grouped="true" style="margin-top: 20px;">

      <flutter-cupertino-list-tile notched="true" @click="logClick('Notched Simple')">
        Notched Title
      </flutter-cupertino-list-tile>

      <flutter-cupertino-list-tile notched="true" show-chevron="true" @click="logClick('Notched with Chevron')">
         <flutter-cupertino-icon 
          slotName="leading" 
          type="folder_fill" 
          style="color: blue; font-size: 22px;"
        ></flutter-cupertino-icon>
        Notched with Leading and Chevron
        <span slotName="subtitle">Some details here</span>
      </flutter-cupertino-list-tile>

       <flutter-cupertino-list-tile notched="true" @click="logClick('Notched Full')">
         <flutter-cupertino-icon 
          slotName="leading" 
          type="person_fill" 
          style="color: green; font-size: 22px;"
        ></flutter-cupertino-icon>
        Contact Name
        <span slotName="subtitle">Last message preview...</span>
        <span slotName="additionalInfo">10:30 AM</span>
         <!-- Note: Trailing widget might look tight in notched style -->
         <flutter-cupertino-icon 
          slotName="trailing" 
          type="info_circle"
          style="color: grey; font-size: 20px;"
         ></flutter-cupertino-icon>
      </flutter-cupertino-list-tile>

    </flutter-cupertino-list-section>

  </div>
</template>

<script>
export default {
  methods: {
    logClick(message) {
      console.log(`ListTile clicked: ${message}`);
    }
  }
}
</script>

<style lang="scss" scoped>
#main {
  background-color: var(--background-primary);
  height: 100vh;
  width: 100vw;
  /* Use webf-listview provided by parent if available, or wrap in one */
   overflow-y: scroll; /* Enable scrolling if content exceeds viewport */
}

/* 
  ListSection and ListTile handle most styling internally based on iOS defaults.
  You can add overrides here if needed.
*/

/* Example styling for slots if needed */
:deep(span[slotName="subtitle"]) {
  color: var(--font-color-secondary);
  font-size: 14px; 
}

:deep(span[slotName="additionalInfo"]) {
  color: var(--font-color-secondary);
  font-size: 14px; 
}

</style> 