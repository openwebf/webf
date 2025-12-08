<template>
  <div id="main">
    <webf-listview id="list">

      <!-- Default Form Section -->
      <flutter-cupertino-form-section>
        <span slotName="header">Account Settings</span>
        
        <flutter-cupertino-form-row>
          <span slotName="prefix">Username</span>
          <flutter-cupertino-input placeholder="Enter username" />
        </flutter-cupertino-form-row>

        <flutter-cupertino-form-row>
          <span slotName="prefix">Email</span>
          <flutter-cupertino-input type="email" placeholder="Enter email" />
          <span slotName="helper">We will send a verification link.</span>
        </flutter-cupertino-form-row>

        <flutter-cupertino-form-row>
          <span slotName="prefix">Notifications</span>
          <flutter-cupertino-switch />
        </flutter-cupertino-form-row>

        <span slotName="footer">
          These settings apply to your main account.
        </span>
      </flutter-cupertino-form-section>

      <!-- Inset Grouped Form Section -->
      <flutter-cupertino-form-section inset-grouped="true" style="margin-top: 20px;">
        <span slotName="header">Preferences</span>

        <flutter-cupertino-form-row>
          <span slotName="prefix">Dark Mode</span>
          <flutter-cupertino-switch />
        </flutter-cupertino-form-row>

        <flutter-cupertino-form-row>
          <span slotName="prefix">Language</span>
          <span>English</span> <!-- Simple text child -->
        </flutter-cupertino-form-row>

        <span slotName="footer">
          Inset grouped sections have rounded corners and padding.
        </span>
      </flutter-cupertino-form-section>

      <!-- Section with Custom Styling -->
       <flutter-cupertino-form-section 
         style="margin-top: 20px; background-color: #e0f7fa; margin-left: 10px; margin-right: 10px; border-radius: 15px;"
       >
        <span slotName="header" style="color: #00796b; font-weight: bold; padding-left: 16px;">Custom Style Section</span>
        
        <flutter-cupertino-form-row style="padding-left: 16px; padding-right: 16px;">
          <span slotName="prefix">Item 1</span>
          <span>Value 1</span>
        </flutter-cupertino-form-row>

        <flutter-cupertino-form-row style="padding-left: 16px; padding-right: 16px;">
          <span slotName="prefix">Item 2</span>
          <span>Value 2</span>
        </flutter-cupertino-form-row>
        
      </flutter-cupertino-form-section>

    </webf-listview>
  </div>
</template>

<script>
export default {
  data() {
    return {}
  },
}
</script>

<style lang="scss" scoped>
#list {
  padding: 10px 0; // Add vertical padding for the list itself
  height: 100vh;
  width: 100vw;
  background-color: var(--background-primary); // Use primary background for the overall page
}

/* 
  Styles for the section content (header, footer, rows) are largely
  determined by the CupertinoFormSection widget itself.
  You can add specific overrides here if needed, but rely on the component's
  default iOS styling first.
*/

/* Example: Styling the header/footer slots if needed */
:deep(span[slotName="header"]) {
  // Default styling provided by CupertinoFormSection is usually sufficient
  // Example override:
  // font-size: 16px; 
  // color: var(--font-color-secondary);
  // margin-bottom: 8px; 
}

:deep(span[slotName="footer"]) {
   // Default styling provided by CupertinoFormSection is usually sufficient
  // Example override:
  // font-size: 12px;
  // color: var(--font-color-tertiary);
  // margin-top: 8px;
}

</style>
