export type Restaurant = {
  slug: string;
  name: string;
  centre: string;
  phone: string;
  address: string[];
  hours: string[];
  serviceTimes?: string[];
  mapEmbed: string;
  mapLink: string;
  menus: { label: string; src: string }[];
};

const ALLERGEN =
  "/menus/glass_house_allergen_info_smaller_2_f4f050d2-fd76-47da-9c3d-4f7372c0e110.jpg";

export const allergenInfo = ALLERGEN;

export const restaurants: Restaurant[] = [
  {
    slug: "fair-oak",
    name: "Charlotte's Restaurant at Fair Oak",
    centre: "In-Excess Fair Oak Garden Centre",
    phone: "02380 697250",
    address: ["Winchester Road", "Fair Oak", "Eastleigh", "SO50 7HD"],
    hours: ["Monday – Saturday: 9.00am – 4.30pm", "Sunday: 10.00am – 3.30pm"],
    mapEmbed:
      "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d1256.0076072215459!2d-1.3066324095823214!3d50.97890938780038!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x48746d74d245d5e7%3A0x58798e66044993ac!2sIn-Excess%20Fair%20Oak%20Garden%20Centre!5e0!3m2!1sen!2suk!4v1575981207254!5m2!1sen!2suk",
    mapLink: "https://www.google.com/maps/search/?api=1&query=In-Excess+Fair+Oak+Garden+Centre",
    menus: [
      { label: "Breakfast", src: "/menus/FO_LF_Breakfast25.jpg" },
      { label: "Lunch", src: "/menus/FO_LF_Lunch25.jpg" },
      { label: "Snacks", src: "/menus/FO_LF_Snacks.jpg" },
      { label: "Children's", src: "/menus/FO_LF_Kids.jpg" },
      { label: "Afternoon Tea", src: "/menus/FO_LF_RW_Afternoon_Tea_NEW.jpg" },
      { label: "Cream Tea", src: "/menus/SGC_Cream_Tea.jpg" },
    ],
  },
  {
    slug: "landford",
    name: "Charlotte's Luxury Restaurant at Landford",
    centre: "In-Excess Landford Garden Centre",
    phone: "01794 390426",
    address: ["Southampton Road", "Landford", "Salisbury", "SP5 2BE"],
    hours: ["Monday – Saturday: 9.00am – 5.30pm", "Sunday: 10.00am – 4.00pm"],
    serviceTimes: [
      "Mon – Sat: Breakfast 9.00 – 11.45 · Lunch 12.00 – 2.30 · High tea 2.30 – 4.30",
      "Sunday: Breakfast 10.00 – 11.30 · Lunch 12.30 – 2.30 · High tea 2.30 – 3.30",
      "Tea, filter coffee and cake served until close",
    ],
    mapEmbed:
      "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2112.4442258072027!2d-1.6282875801082732!3d50.97671920210393!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x48738d3e3f5278f1%3A0xc02925c88bd5ce08!2sIn-Excess%20Landford%20Garden%20Centre!5e0!3m2!1sen!2suk!4v1575981457508!5m2!1sen!2suk",
    mapLink: "https://www.google.com/maps/search/?api=1&query=In-Excess+Landford+Garden+Centre",
    menus: [
      { label: "Breakfast", src: "/menus/FO_LF_Breakfast25.jpg" },
      { label: "Lunch", src: "/menus/FO_LF_Lunch25.jpg" },
      { label: "Snacks", src: "/menus/FO_LF_Snacks.jpg" },
      { label: "Children's", src: "/menus/FO_LF_Kids.jpg" },
      { label: "Afternoon Tea", src: "/menus/FO_LF_RW_Afternoon_Tea_NEW.jpg" },
      { label: "Cream Tea", src: "/menus/SGC_Cream_Tea.jpg" },
    ],
  },
  {
    slug: "ringwood",
    name: "Charlotte's Tea Room at Ringwood",
    centre: "In-Excess Ringwood Garden Centre",
    phone: "01425 489328",
    address: ["Forest Corner", "Poulner Hill", "Ringwood", "BH24 3HW"],
    hours: ["Monday – Saturday: 9.30am – 4.30pm", "Sunday: 10.00am – 3.00pm"],
    mapEmbed:
      "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d1781.1357921867582!2d-1.7506827525780426!3d50.85141763940678!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x48739095614597cd%3A0x26acd6203a511147!2sIn-Excess%20Ringwood%20Garden%20Centre!5e0!3m2!1sen!2suk!4v1575982371373!5m2!1sen!2suk",
    mapLink: "https://www.google.com/maps/search/?api=1&query=In-Excess+Ringwood+Garden+Centre",
    menus: [
      { label: "Breakfast", src: "/menus/RW_Breakfast25.jpg" },
      { label: "Lunch", src: "/menus/RW_Lunch25.jpg" },
      { label: "Afternoon Tea", src: "/menus/FO_LF_RW_Afternoon_Tea_NEW.jpg" },
      { label: "Cream Tea", src: "/menus/SGC_Cream_Tea.jpg" },
    ],
  },
  {
    slug: "salisbury",
    name: "Charlotte's Tea Room at Salisbury",
    centre: "In-Excess Salisbury Garden Centre",
    phone: "01722 744918",
    address: ["Netherhampton Road", "Salisbury", "SP2 8PR"],
    hours: ["Monday – Saturday: 9.30am – 4.30pm", "Sunday: 10.00am – 3.00pm"],
    mapEmbed:
      "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2507.448437626914!2d-1.8388582485006204!3d51.06327147946431!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x4873eb4212bf40f1%3A0x762ccbf0d4c7053e!2sIn-Excess%20Salisbury%20Garden%20Centre!5e0!3m2!1sen!2suk!4v1575982613615!5m2!1sen!2suk",
    mapLink: "https://www.google.com/maps/search/?api=1&query=In-Excess+Salisbury+Garden+Centre",
    menus: [
      { label: "Savoury", src: "/menus/SGC_Savoury_DraftREDUCED25_copy.jpg" },
      { label: "Sweet", src: "/menus/SGC_Sweet_DraftREDUCED25_copy.jpg" },
      { label: "Cream Tea", src: "/menus/SGC_Cream_Tea.jpg" },
    ],
  },
];

export const getRestaurant = (slug: string) => restaurants.find((r) => r.slug === slug);
